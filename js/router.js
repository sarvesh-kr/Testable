import {
  createEl,
  formatSeconds,
  getFromStorage,
  getQueryParam,
  navigate,
  removeFromStorage,
  saveToStorage,
  setupThemeToggle
} from "./app.js";
import {
  clearAnswer,
  getQuestionStatus,
  loadOrCreateState,
  markReview,
  moveTo,
  persistState,
  setAnswer
} from "./questionEngine.js";
import { getExamById, loadExams, loadQuestionSet, loadTopics } from "./examLoader.js";
import {
  buildResult,
  evaluateResponse,
  formatAnswerForDisplay,
  inferQuestionType,
  isResponseEmpty,
  summaryItems
} from "./resultEngine.js";
import { TestTimer } from "./timer.js";

let timer = null;
let activeAttempt = null;
let activeQuestions = [];
let activeState = null;
let isSubmitting = false;

function shuffleArray(items) {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    const tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }
  return arr;
}

function setMockConfigStatus(message, tone = "") {
  const status = document.getElementById("mock-config-status");
  if (!status) {
    return;
  }

  status.className = tone ? tone : "muted";
  status.textContent = message;
}

const DEFAULT_MOCK_TOPIC_SELECTION = new Set([
  "computer_networks_cyber_security",
  "database_management_system",
  "operating_system",
  "software_engineering",
  "computer_architecture",
  "data_structure_algorithm"
]);

function buildAllocationPlan(topicConfigs, targetCount) {
  const selected = topicConfigs.filter((cfg) => cfg.selected);
  if (!selected.length) {
    throw new Error("Select at least one topic.");
  }

  if (!Number.isInteger(targetCount) || targetCount <= 0) {
    throw new Error("Total questions must be greater than 0.");
  }

  const exact = [];
  const upto = [];
  selected.forEach((cfg) => {
    const available = cfg.topic.questionCount;
    const cap = Math.min(Math.max(0, cfg.limit), available);
    const normalized = {
      topic: cfg.topic,
      exact: cfg.exact,
      cap,
      available
    };

    if (cfg.exact) {
      if (cap <= 0) {
        throw new Error(`Exact count must be at least 1 for ${cfg.topic.name}.`);
      }
      exact.push(normalized);
    } else {
      upto.push(normalized);
    }
  });

  const allocation = {};
  let fixedCount = 0;

  exact.forEach((cfg) => {
    allocation[cfg.topic.id] = cfg.cap;
    fixedCount += cfg.cap;
  });

  if (fixedCount > targetCount) {
    throw new Error(`Exact allocations exceed target (${fixedCount}/${targetCount}).`);
  }

  let remaining = targetCount - fixedCount;
  const flexibleCapacity = upto.reduce((sum, cfg) => sum + cfg.cap, 0);
  if (remaining > flexibleCapacity) {
    throw new Error("Not enough capacity in flexible topics to reach target count.");
  }

  upto.forEach((cfg) => {
    allocation[cfg.topic.id] = 0;
  });

  const poolsByLeft = upto.map((cfg) => ({
    id: cfg.topic.id,
    left: cfg.cap
  }));

  // Deterministic round-robin distribution keeps preview and final build aligned.
  while (remaining > 0) {
    let progressed = false;
    poolsByLeft.sort((a, b) => b.left - a.left);

    for (const candidate of poolsByLeft) {
      if (candidate.left <= 0 || remaining <= 0) {
        continue;
      }

      allocation[candidate.id] += 1;
      candidate.left -= 1;
      remaining -= 1;
      progressed = true;
    }

    if (!progressed) {
      break;
    }
  }

  return {
    selected,
    allocation,
    targetCount
  };
}

async function buildPersonalizedMockQuestions(plan) {
  const pools = {};
  for (const cfg of plan.selected) {
    const filePath = `./data/topics/${cfg.topic.file}`;
    const questions = (await loadQuestionSet(filePath)).filter(isValidQuestion);
    if (!questions.length) {
      throw new Error(`No valid questions found in ${cfg.topic.name}.`);
    }
    pools[cfg.topic.id] = shuffleArray(questions);
  }

  const finalQuestions = [];
  plan.selected.forEach((cfg) => {
    const take = plan.allocation[cfg.topic.id] || 0;
    if (take > 0) {
      finalQuestions.push(...pools[cfg.topic.id].slice(0, take));
    }
  });

  if (finalQuestions.length !== plan.targetCount) {
    throw new Error(`Unable to construct target size mock (${finalQuestions.length}/${plan.targetCount}).`);
  }

  return shuffleArray(finalQuestions);
}

function showError(message) {
  const panel = document.querySelector(".panel");
  if (!panel) {
    return;
  }

  panel.innerHTML = "";
  const title = createEl("h1", "", "Unable to Continue");
  const body = createEl("p", "muted", message);
  const back = createEl("a", "btn ghost", "Go to Dashboard");
  back.href = "index.html";
  panel.append(title, body, back);
}

function isValidQuestion(question) {
  if (!question || typeof question.question !== "string" || question.question.trim().length === 0) {
    return false;
  }

  if (typeof question.explanation !== "string") {
    return false;
  }

  const type = inferQuestionType(question);
  if (type === "text") {
    if (Array.isArray(question.answer)) {
      return question.answer.length > 0 && question.answer.every((value) => String(value).trim().length > 0);
    }
    return String(question.answer ?? "").trim().length > 0;
  }

  if (!Array.isArray(question.options) || question.options.length < 2) {
    return false;
  }

  if (question.options.some((opt) => typeof opt !== "string" || opt.trim().length === 0)) {
    return false;
  }

  if (type === "multi") {
    return (
      Array.isArray(question.answer) &&
      question.answer.length > 0 &&
      question.answer.every((idx) => Number.isInteger(idx) && idx >= 0 && idx < question.options.length)
    );
  }

  return (
    Number.isInteger(question.answer) &&
    question.answer >= 0 &&
    question.answer < question.options.length
  );
}

function requireExamId() {
  const byQuery = getQueryParam("exam");
  const stored = getFromStorage("selectedExam", null);
  const examId = byQuery || stored?.id;

  if (!examId) {
    navigate("index.html");
    return null;
  }

  return examId;
}

function setSelectedExam(exam) {
  saveToStorage("selectedExam", exam);
}

function buildAttemptQuestionKey(attemptId) {
  return `otp_attempt_questions_${attemptId}`;
}

function buildAttempt({ examId, mode, id, title, filePath, durationMinutes }) {
  return {
    attemptId: `${mode}_${id}_${Date.now()}`,
    examId,
    mode,
    id,
    title,
    filePath,
    durationMinutes
  };
}

function startAttempt(attempt) {
  saveToStorage("currentAttempt", attempt);
  navigate("test.html");
}

async function initDashboard() {
  const exams = await loadExams();
  const grid = document.getElementById("exam-grid");

  exams.forEach((exam) => {
    const card = createEl("article", "card");
    card.append(
      createEl("h3", "", exam.name),
      createEl("p", "muted", "Launch exam hub and pick mock or topic tests.")
    );

    const action = createEl("button", "btn primary", "Open Exam");
    action.type = "button";
    action.addEventListener("click", () => {
      setSelectedExam(exam);
      navigate(`exam.html?exam=${exam.id}`);
    });

    card.append(action);
    grid.append(card);
  });
}

async function initExamPage() {
  const examId = requireExamId();
  if (!examId) {
    return;
  }

  const exam = await getExamById(examId);
  if (!exam) {
    showError("Exam not found.");
    return;
  }

  setSelectedExam(exam);
  document.getElementById("exam-name").textContent = exam.name;
}

async function initTestType() {
  const examId = requireExamId();
  if (!examId) {
    return;
  }

  const exam = await getExamById(examId);
  if (!exam) {
    showError("Exam not found.");
    return;
  }

  document.getElementById("test-type-exam").textContent = `Exam: ${exam.name}`;
}

async function initMockList() {
  const examId = requireExamId();
  if (!examId) {
    return;
  }

  const exam = await getExamById(examId);
  if (!exam) {
    showError("Exam not found.");
    return;
  }

  const topics = await loadTopics(examId);

  const listWrap = document.getElementById("mock-list");
  const configPanel = document.getElementById("mock-config-panel");
  const configTitle = document.getElementById("mock-config-title");
  const configTarget = document.getElementById("mock-config-target");
  const configSummary = document.getElementById("mock-config-summary");
  const totalQuestionsInput = document.getElementById("mock-total-questions");
  const totalQuestionsValue = document.getElementById("mock-total-questions-value");
  const durationInput = document.getElementById("mock-duration-minutes");
  const durationValue = document.getElementById("mock-duration-minutes-value");
  const topicList = document.getElementById("topic-config-list");
  const allocationPreview = document.getElementById("topic-allocation-preview");
  const generateBtn = document.getElementById("mock-config-generate");
  const cancelBtn = document.getElementById("mock-config-cancel");

  let activeMock = null;
  let topicConfigs = [];
  let latestPlan = null;

  function hideConfigurator() {
    activeMock = null;
    topicConfigs = [];
    latestPlan = null;
    topicList.innerHTML = "";
    allocationPreview.innerHTML = "";
    configPanel.classList.add("hidden");
    setMockConfigStatus("", "");
  }

  function getConfiguredTotalQuestions() {
    return Number(totalQuestionsInput.value);
  }

  function getConfiguredDurationMinutes() {
    return Number(durationInput.value);
  }

  function renderAllocationPreview(plan) {
    const rows = plan.selected
      .map((cfg) => ({
        name: cfg.topic.name,
        mode: cfg.exact ? "Exact" : "Up to",
        cap: cfg.cap,
        allocated: plan.allocation[cfg.topic.id] || 0
      }))
      .sort((a, b) => b.allocated - a.allocated);

    if (!rows.length) {
      allocationPreview.innerHTML = "<p class=\"muted\">No topic selected.</p>";
      return;
    }

    const table = createEl("table");
    const thead = createEl("thead");
    const hrow = createEl("tr");
    ["Topic", "Mode", "Cap", "Final Allocation"].forEach((label) => {
      hrow.append(createEl("th", "", label));
    });
    thead.append(hrow);

    const tbody = createEl("tbody");
    rows.forEach((row) => {
      const tr = createEl("tr");
      tr.append(
        createEl("td", "", row.name),
        createEl("td", "", row.mode),
        createEl("td", "", String(row.cap)),
        createEl("td", "", String(row.allocated))
      );
      tbody.append(tr);
    });

    const total = rows.reduce((sum, row) => sum + row.allocated, 0);
    const totalRow = createEl("tr");
    totalRow.append(
      createEl("td", "", "Total"),
      createEl("td", "", "-"),
      createEl("td", "", "-"),
      createEl("td", "", String(total))
    );
    tbody.append(totalRow);

    table.append(thead, tbody);
    allocationPreview.innerHTML = "";
    allocationPreview.append(table);
  }

  function updateConfiguratorSummary() {
    if (!activeMock) {
      return;
    }

    const targetQuestions = getConfiguredTotalQuestions();
    const targetDuration = getConfiguredDurationMinutes();
    const selected = topicConfigs.filter((cfg) => cfg.selected);
    const exactTotal = selected.filter((cfg) => cfg.exact).reduce((sum, cfg) => sum + cfg.limit, 0);
    const flexibleCapacity = selected
      .filter((cfg) => !cfg.exact)
      .reduce((sum, cfg) => sum + cfg.limit, 0);
    const remaining = targetQuestions - exactTotal;

    configSummary.textContent = `Target: ${targetQuestions} | Duration: ${targetDuration} mins | Selected Topics: ${selected.length} | Exact: ${exactTotal} | Flexible Capacity: ${flexibleCapacity}`;

    if (!selected.length) {
      latestPlan = null;
      allocationPreview.innerHTML = "";
      setMockConfigStatus("Select at least one topic.", "error");
      return;
    }

    if (exactTotal > targetQuestions) {
      latestPlan = null;
      allocationPreview.innerHTML = "";
      setMockConfigStatus("Exact allocations exceed total target. Reduce one or more topic caps.", "error");
      return;
    }

    if (remaining > flexibleCapacity) {
      latestPlan = null;
      allocationPreview.innerHTML = "";
      setMockConfigStatus("Increase flexible topic caps or reduce exact allocations to reach target.", "error");
      return;
    }

    try {
      latestPlan = buildAllocationPlan(topicConfigs, targetQuestions);
      renderAllocationPreview(latestPlan);
    } catch (error) {
      latestPlan = null;
      allocationPreview.innerHTML = "";
      setMockConfigStatus(error.message || "Invalid configuration.", "error");
      return;
    }

    setMockConfigStatus("Configuration looks valid. You can generate the mock now.", "success");
  }

  function renderTopicConfigRow(cfg) {
    const row = createEl("article", "topic-config-item");
    const head = createEl("div", "topic-config-head");

    const includeWrap = createEl("label", "row");
    const include = createEl("input");
    include.type = "checkbox";
    include.checked = cfg.selected;
    const includeTxt = createEl("span", "", cfg.topic.name);
    includeWrap.append(include, includeTxt);

    const available = createEl("span", "muted", `Pool: ${cfg.topic.questionCount}`);
    head.append(includeWrap, available);

    const controls = createEl("div", "topic-config-controls");
    const sliderRow = createEl("div", "slider-row");
    const range = createEl("input");
    range.type = "range";
    range.min = "0";
    range.max = String(cfg.topic.questionCount);
    range.value = String(cfg.limit);
    range.disabled = !cfg.selected;

    const valueText = createEl("span", "topic-cap-value", String(cfg.limit));
    sliderRow.append(range, valueText);

    const exactWrap = createEl("label", "row muted");
    const exact = createEl("input");
    exact.type = "checkbox";
    exact.checked = cfg.exact;
    exact.disabled = !cfg.selected;
    const exactTxt = createEl("span", "", "Exactly this many (otherwise up to this cap)");
    exactWrap.append(exact, exactTxt);

    controls.append(sliderRow, exactWrap);
    row.append(head, controls);

    include.addEventListener("change", () => {
      cfg.selected = include.checked;
      range.disabled = !cfg.selected;
      exact.disabled = !cfg.selected;
      if (!cfg.selected) {
        cfg.exact = false;
        exact.checked = false;
      }
      updateConfiguratorSummary();
    });

    range.addEventListener("input", () => {
      cfg.limit = Number(range.value);
      valueText.textContent = String(cfg.limit);
      updateConfiguratorSummary();
    });

    exact.addEventListener("change", () => {
      cfg.exact = exact.checked;
      updateConfiguratorSummary();
    });

    return row;
  }

  function renderTopicRows() {
    topicList.innerHTML = "";
    topicConfigs.forEach((cfg) => {
      topicList.append(renderTopicConfigRow(cfg));
    });
  }

  function openConfigurator(mock) {
    activeMock = mock;
    const totalPool = topics.reduce((sum, t) => sum + t.questionCount, 0);
    const maxQuestions = Math.min(500, totalPool);

    totalQuestionsInput.min = "10";
    totalQuestionsInput.max = String(Math.max(10, maxQuestions));
    totalQuestionsInput.value = String(Math.min(mock.questionCount, maxQuestions));
    totalQuestionsValue.textContent = totalQuestionsInput.value;

    durationInput.min = "15";
    durationInput.max = "300";
    durationInput.value = String(Math.min(300, Math.max(15, mock.durationMinutes)));
    durationValue.textContent = durationInput.value;

    const defaultCap = Math.max(1, Math.floor(getConfiguredTotalQuestions() / Math.max(1, topics.length)));
    topicConfigs = topics.map((topic) => ({
      topic,
      selected: DEFAULT_MOCK_TOPIC_SELECTION.has(topic.id),
      exact: false,
      limit: Math.min(defaultCap, topic.questionCount, getConfiguredTotalQuestions())
    }));

    configTitle.textContent = `${mock.title} Personalization`;
    configTarget.textContent = "Set total questions, duration, and topic-wise allocation.";
    renderTopicRows();

    configPanel.classList.remove("hidden");
    updateConfiguratorSummary();
    configPanel.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  totalQuestionsInput.addEventListener("input", () => {
    if (!activeMock) {
      return;
    }

    totalQuestionsValue.textContent = totalQuestionsInput.value;
    topicConfigs.forEach((cfg) => {
      cfg.limit = Math.min(cfg.limit, cfg.topic.questionCount);
    });
    renderTopicRows();
    updateConfiguratorSummary();
  });

  durationInput.addEventListener("input", () => {
    durationValue.textContent = durationInput.value;
    updateConfiguratorSummary();
  });

  exam.mockTests.forEach((mock) => {
    const card = createEl("article", "card");
    card.append(
      createEl("h3", "", mock.title),
      createEl("p", "muted", `Questions: ${mock.questionCount} | Time: ${mock.durationMinutes} mins`)
    );
    const btn = createEl("button", "btn primary", "Personalize and Start");
    btn.type = "button";
    btn.addEventListener("click", () => {
      openConfigurator(mock);
    });

    card.append(btn);
    listWrap.append(card);
  });

  cancelBtn.addEventListener("click", () => {
    hideConfigurator();
  });

  generateBtn.addEventListener("click", async () => {
    if (!activeMock) {
      return;
    }

    try {
      generateBtn.disabled = true;
      setMockConfigStatus("Generating personalized mock from selected topics...", "muted");

      if (!latestPlan) {
        throw new Error("Please resolve configuration errors before generating.");
      }

      const questions = await buildPersonalizedMockQuestions(latestPlan);
      const attempt = buildAttempt({
        examId,
        mode: "mock",
        id: activeMock.id,
        title: `${activeMock.title} (Personalized, ${latestPlan.targetCount}Q)`,
        filePath: "",
        durationMinutes: getConfiguredDurationMinutes()
      });

      const customQuestionsKey = `otp_custom_questions_${attempt.attemptId}`;
      saveToStorage(customQuestionsKey, questions);
      const persisted = getFromStorage(customQuestionsKey, null);
      if (!Array.isArray(persisted) || persisted.length !== questions.length) {
        removeFromStorage(customQuestionsKey);
        throw new Error(
          "Unable to persist personalized mock data. Reduce total questions and try again."
        );
      }
      attempt.customQuestionsKey = customQuestionsKey;
      startAttempt(attempt);
    } catch (error) {
      setMockConfigStatus(error.message || "Failed to generate personalized mock.", "error");
    } finally {
      generateBtn.disabled = false;
    }
  });
}

async function initTopicList() {
  const examId = requireExamId();
  if (!examId) {
    return;
  }

  const topics = await loadTopics(examId);
  const listWrap = document.getElementById("topic-list");

  topics.forEach((topic) => {
    const card = createEl("article", "card");
    card.append(
      createEl("h3", "", topic.name),
      createEl("p", "muted", `Questions: ${topic.questionCount} | Time: ${topic.durationMinutes} mins`)
    );
    const btn = createEl("button", "btn secondary", "Start Topic Test");
    btn.type = "button";
    btn.addEventListener("click", () => {
      startAttempt(
        buildAttempt({
          examId,
          mode: "topic",
          id: topic.id,
          title: topic.name,
          filePath: `./data/topics/${topic.file}`,
          durationMinutes: topic.durationMinutes
        })
      );
    });

    card.append(btn);
    listWrap.append(card);
  });
}

function getSelectedResponse() {
  const question = activeQuestions[activeState.currentIndex];
  const type = inferQuestionType(question);

  if (type === "text") {
    const textInput = document.getElementById("answer-input-text");
    return textInput ? textInput.value.trim() : "";
  }

  if (type === "multi") {
    const checked = Array.from(document.querySelectorAll('input[name="answer-option"]:checked')).map((el) => Number(el.value));
    return checked;
  }

  const checked = document.querySelector('input[name="answer-option"]:checked');
  return checked ? Number(checked.value) : null;
}

function resetAnswerFeedback() {
  const feedback = document.getElementById("answer-feedback");
  if (!feedback) {
    return;
  }

  feedback.className = "answer-feedback hidden";
  feedback.textContent = "";
}

function showAnswerFeedback(response) {
  const feedback = document.getElementById("answer-feedback");
  if (!feedback) {
    return;
  }

  const question = activeQuestions[activeState.currentIndex];
  const type = inferQuestionType(question);
  if (isResponseEmpty(response, type)) {
    feedback.className = "answer-feedback wrong";
    feedback.textContent = "Please provide an answer before checking.";
    return;
  }

  const correct = evaluateResponse(question, response);
  const yourAnswer = formatAnswerForDisplay(question, response);
  const expected = formatAnswerForDisplay(question, question.answer);
  const explanation = question.explanation || "No explanation provided.";

  feedback.className = `answer-feedback ${correct ? "correct" : "wrong"}`;
  feedback.innerHTML = "";

  const heading = createEl("strong", "", correct ? "Correct" : "Not Correct");
  const your = createEl("p", "", `Your Answer: ${yourAnswer}`);
  const right = createEl("p", "", `Correct Answer: ${expected}`);
  const explain = createEl("p", "", `Explanation: ${explanation}`);
  feedback.append(heading, your, right, explain);
}

function renderQuestion() {
  const question = activeQuestions[activeState.currentIndex];
  const questionText = document.getElementById("question-text");
  const questionIndex = document.getElementById("question-index");
  const optionsWrap = document.getElementById("options-wrap");

  questionIndex.textContent = `Question ${activeState.currentIndex + 1} of ${activeQuestions.length}`;
  questionText.textContent = question.question;
  optionsWrap.innerHTML = "";
  resetAnswerFeedback();

  const type = inferQuestionType(question);

  if (type === "text") {
    const input = createEl("input");
    input.id = "answer-input-text";
    input.type = "text";
    input.className = "input-text-answer";
    input.placeholder = "Type your answer";
    const saved = activeState.answers[activeState.currentIndex];
    if (typeof saved === "string") {
      input.value = saved;
    }
    optionsWrap.append(input);
    return;
  }

  const inputType = type === "multi" ? "checkbox" : "radio";
  const savedAnswer = activeState.answers[activeState.currentIndex];
  const selectedSet = Array.isArray(savedAnswer)
    ? new Set(savedAnswer.map((val) => Number(val)))
    : new Set([Number(savedAnswer)]);

  question.options.forEach((option, idx) => {
    const wrapper = createEl("label", "option");
    const input = createEl("input");
    input.type = inputType;
    input.name = "answer-option";
    input.value = String(idx);

    if (selectedSet.has(idx)) {
      input.checked = true;
    }

    const txt = createEl("span", "", option);
    wrapper.append(input, txt);
    optionsWrap.append(wrapper);
  });
}

function renderPalette() {
  const palette = document.getElementById("question-palette");
  palette.innerHTML = "";

  for (let i = 0; i < activeQuestions.length; i += 1) {
    const stateClass = getQuestionStatus(activeState, i);
    const btn = createEl("button", `palette-btn ${stateClass}`, String(i + 1));
    btn.type = "button";
    btn.addEventListener("click", () => {
      moveTo(activeState, i);
      persistState(activeState);
      renderQuestion();
      renderPalette();
    });
    palette.append(btn);
  }
}

function syncTimerToState(seconds) {
  activeState.remainingSeconds = Math.max(0, seconds);
  persistState(activeState);
  document.getElementById("timer-display").textContent = formatSeconds(seconds);
}

function submitTest() {
  if (isSubmitting) {
    return;
  }

  isSubmitting = true;

  if (timer) {
    timer.stop();
  }

  const result = buildResult({
    questions: activeQuestions,
    answers: activeState.answers,
    startedAt: activeState.startedAt,
    submittedAt: Date.now(),
    allottedSeconds: activeAttempt.durationMinutes * 60,
    title: activeAttempt.title
  });

  saveToStorage("lastResult", result);
  removeFromStorage(`otp_progress_${activeAttempt.attemptId}`);
  if (activeAttempt.customQuestionsKey) {
    removeFromStorage(activeAttempt.customQuestionsKey);
  }
  if (activeAttempt.questionSetKey) {
    removeFromStorage(activeAttempt.questionSetKey);
  }
  removeFromStorage("currentAttempt");
  navigate("result.html");
}

function initTestActions() {
  document.getElementById("prev-btn").addEventListener("click", () => {
    moveTo(activeState, activeState.currentIndex - 1);
    persistState(activeState);
    renderQuestion();
    renderPalette();
  });

  document.getElementById("save-next-btn").addEventListener("click", () => {
    const selected = getSelectedResponse();
    if (isResponseEmpty(selected, inferQuestionType(activeQuestions[activeState.currentIndex]))) {
      clearAnswer(activeState, activeState.currentIndex);
    } else {
      setAnswer(activeState, activeState.currentIndex, selected);
    }

    moveTo(activeState, activeState.currentIndex + 1);
    persistState(activeState);
    renderQuestion();
    renderPalette();
  });

  document.getElementById("mark-review-btn").addEventListener("click", () => {
    const selected = getSelectedResponse();
    if (isResponseEmpty(selected, inferQuestionType(activeQuestions[activeState.currentIndex]))) {
      clearAnswer(activeState, activeState.currentIndex);
    } else {
      setAnswer(activeState, activeState.currentIndex, selected);
    }

    markReview(activeState, activeState.currentIndex);
    moveTo(activeState, activeState.currentIndex + 1);
    persistState(activeState);
    renderQuestion();
    renderPalette();
  });

  document.getElementById("submit-btn").addEventListener("click", () => {
    const shouldSubmit = window.confirm("Submit test now?");
    if (shouldSubmit) {
      submitTest();
    }
  });

  const checkBtn = document.getElementById("check-answer-btn");
  if (checkBtn) {
    checkBtn.addEventListener("click", () => {
      const selected = getSelectedResponse();
      const type = inferQuestionType(activeQuestions[activeState.currentIndex]);

      if (!isResponseEmpty(selected, type)) {
        setAnswer(activeState, activeState.currentIndex, selected);
        persistState(activeState);
        renderPalette();
      }

      showAnswerFeedback(selected);
    });
  }
}

async function initTestPage() {
  isSubmitting = false;
  activeAttempt = getFromStorage("currentAttempt", null);
  if (!activeAttempt) {
    showError("No active test session found.");
    return;
  }

  if (activeAttempt.customQuestionsKey) {
    activeQuestions = getFromStorage(activeAttempt.customQuestionsKey, []).filter(isValidQuestion);
  } else {
    let questionSetKey = activeAttempt.questionSetKey;
    if (!questionSetKey) {
      questionSetKey = buildAttemptQuestionKey(activeAttempt.attemptId);
      activeAttempt.questionSetKey = questionSetKey;
      saveToStorage("currentAttempt", activeAttempt);
    }

    const persistedQuestions = getFromStorage(questionSetKey, null);
    if (Array.isArray(persistedQuestions) && persistedQuestions.length > 0) {
      activeQuestions = persistedQuestions.filter(isValidQuestion);
    } else {
      // For non-custom tests, shuffle once per attempt and persist to keep order stable on refresh.
      const loaded = (await loadQuestionSet(activeAttempt.filePath)).filter(isValidQuestion);
      activeQuestions = shuffleArray(loaded);
      saveToStorage(questionSetKey, activeQuestions);
    }
  }

  if (!activeQuestions.length) {
    showError("No questions found for this test.");
    return;
  }

  activeState = loadOrCreateState(activeAttempt, activeQuestions);

  document.title = `${activeAttempt.title} - Online Test Platform`;
  document.getElementById("test-title").textContent = activeAttempt.title;
  renderQuestion();
  renderPalette();
  initTestActions();

  window.addEventListener("beforeunload", () => {
    if (timer) {
      timer.stop();
    }
  });

  timer = new TestTimer({
    durationSeconds: activeState.remainingSeconds,
    onTick: syncTimerToState,
    onExpire: submitTest
  });

  timer.start();
}

function initResultPage() {
  const result = getFromStorage("lastResult", null);
  if (!result) {
    showError("No result available. Start a test first.");
    return;
  }

  if (result.title) {
    document.title = `${result.title} Result - Online Test Platform`;
  }

  const summaryWrap = document.getElementById("result-summary");
  summaryItems(result).forEach((item) => {
    const card = createEl("article", "stat");
    card.append(createEl("p", "", item.label), createEl("strong", "", String(item.value)));
    summaryWrap.append(card);
  });

  const reviewWrap = document.getElementById("review-wrap");
  result.review.forEach((row) => {
    const selected = formatAnswerForDisplay(row, row.selected);
    const correct = formatAnswerForDisplay(row, row.correctAnswer);
    const item = createEl("article", `review-item ${row.isCorrect ? "correct" : "wrong"}`);
    const title = createEl("h3", "", `Q${row.questionNo}. ${row.question}`);
    const yourAns = createEl("p");
    yourAns.append(createEl("strong", "", "Your Answer: "), document.createTextNode(selected));
    const correctAns = createEl("p");
    correctAns.append(createEl("strong", "", "Correct Answer: "), document.createTextNode(correct));
    const explanation = createEl("p");
    explanation.append(createEl("strong", "", "Explanation: "), document.createTextNode(row.explanation));
    item.append(title, yourAns, correctAns, explanation);
    reviewWrap.append(item);
  });
}

async function bootstrap() {
  setupThemeToggle();

  // This shared router initializes the module matching each page's data-page id.
  const page = document.body.dataset.page;
  const routes = {
    dashboard: initDashboard,
    exam: initExamPage,
    "test-type": initTestType,
    "mock-list": initMockList,
    "topic-list": initTopicList,
    test: initTestPage,
    result: initResultPage
  };

  const handler = routes[page];
  if (!handler) {
    return;
  }

  try {
    await handler();
  } catch (error) {
    showError(error.message || "Something went wrong while loading the page.");
  }
}

bootstrap();
