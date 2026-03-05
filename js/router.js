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
import { buildResult, summaryItems } from "./resultEngine.js";
import { TestTimer } from "./timer.js";

let timer = null;
let activeAttempt = null;
let activeQuestions = [];
let activeState = null;
let isSubmitting = false;

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
  return (
    question &&
    typeof question.question === "string" &&
    question.question.trim().length > 0 &&
    Array.isArray(question.options) &&
    question.options.length === 4 &&
    question.options.every((opt) => typeof opt === "string" && opt.trim().length > 0) &&
    Number.isInteger(question.answer) &&
    question.answer >= 0 &&
    question.answer <= 3 &&
    typeof question.explanation === "string"
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

  const listWrap = document.getElementById("mock-list");
  exam.mockTests.forEach((mock) => {
    const card = createEl("article", "card");
    card.append(
      createEl("h3", "", mock.title),
      createEl("p", "muted", `Questions: ${mock.questionCount} | Time: ${mock.durationMinutes} mins`)
    );
    const btn = createEl("button", "btn primary", "Start Test");
    btn.type = "button";
    btn.addEventListener("click", () => {
      startAttempt(
        buildAttempt({
          examId,
          mode: "mock",
          id: mock.id,
          title: mock.title,
          filePath: `./data/mocks/${mock.file}`,
          durationMinutes: mock.durationMinutes
        })
      );
    });

    card.append(btn);
    listWrap.append(card);
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

function getSelectedOption() {
  const checked = document.querySelector('input[name="answer-option"]:checked');
  if (!checked) {
    return null;
  }

  return Number(checked.value);
}

function renderQuestion() {
  const question = activeQuestions[activeState.currentIndex];
  const questionText = document.getElementById("question-text");
  const questionIndex = document.getElementById("question-index");
  const optionsWrap = document.getElementById("options-wrap");

  questionIndex.textContent = `Question ${activeState.currentIndex + 1} of ${activeQuestions.length}`;
  questionText.textContent = question.question;
  optionsWrap.innerHTML = "";

  question.options.forEach((option, idx) => {
    const wrapper = createEl("label", "option");
    const input = createEl("input");
    input.type = "radio";
    input.name = "answer-option";
    input.value = String(idx);

    if (Number(activeState.answers[activeState.currentIndex]) === idx) {
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
    const selected = getSelectedOption();
    if (selected === null) {
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
    const selected = getSelectedOption();
    if (selected === null) {
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
}

async function initTestPage() {
  isSubmitting = false;
  activeAttempt = getFromStorage("currentAttempt", null);
  if (!activeAttempt) {
    showError("No active test session found.");
    return;
  }

  // Question sets are selected via metadata and loaded from JSON paths.
  activeQuestions = (await loadQuestionSet(activeAttempt.filePath)).filter(isValidQuestion);
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
    const selected = row.selected !== undefined ? row.options[row.selected] : "Not Attempted";
    const correct = row.options[row.correctAnswer];
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
