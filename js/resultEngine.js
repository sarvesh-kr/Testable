import { formatSeconds } from "./app.js";

export function inferQuestionType(question) {
  if (question && typeof question.type === "string") {
    return question.type;
  }

  if (Array.isArray(question?.answer)) {
    return "multi";
  }

  if (!Array.isArray(question?.options) || question.options.length === 0) {
    return "text";
  }

  return "single";
}

function normalizeText(value) {
  return String(value ?? "").trim().toLowerCase();
}

export function isResponseEmpty(response, type) {
  if (response === null || response === undefined) {
    return true;
  }

  if (type === "multi") {
    return !Array.isArray(response) || response.length === 0;
  }

  if (type === "text") {
    return normalizeText(response).length === 0;
  }

  return false;
}

function arraysEqualAsSets(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b) || a.length !== b.length) {
    return false;
  }

  const x = [...a].map(Number).sort((m, n) => m - n);
  const y = [...b].map(Number).sort((m, n) => m - n);
  return x.every((value, index) => value === y[index]);
}

export function evaluateResponse(question, response) {
  const type = inferQuestionType(question);
  if (isResponseEmpty(response, type)) {
    return false;
  }

  if (type === "multi") {
    return arraysEqualAsSets(response, question.answer);
  }

  if (type === "text") {
    if (Array.isArray(question.answer)) {
      return question.answer.some((candidate) => normalizeText(candidate) === normalizeText(response));
    }
    return normalizeText(response) === normalizeText(question.answer);
  }

  return Number(response) === Number(question.answer);
}

export function formatAnswerForDisplay(question, response) {
  const type = inferQuestionType(question);
  if (isResponseEmpty(response, type)) {
    return "Not Attempted";
  }

  if (type === "multi") {
    if (!Array.isArray(question.options)) {
      return String(response);
    }
    return response
      .map((idx) => question.options[Number(idx)] ?? `Option ${Number(idx) + 1}`)
      .join(", ");
  }

  if (type === "text") {
    if (Array.isArray(response)) {
      return response.join(", ");
    }
    return String(response);
  }

  if (Array.isArray(question.options)) {
    const idx = Number(response);
    return question.options[idx] ?? String(response);
  }

  return String(response);
}

export function buildResult({ questions, answers, startedAt, submittedAt, allottedSeconds, title }) {
  let correct = 0;
  let wrong = 0;
  let attempted = 0;

  const review = questions.map((question, index) => {
    const type = inferQuestionType(question);
    const selected = answers[index];
    const answered = !isResponseEmpty(selected, type);
    const isCorrect = evaluateResponse(question, selected);

    if (answered) {
      attempted += 1;
    }

    if (answered && isCorrect) {
      correct += 1;
    }

    if (answered && !isCorrect) {
      wrong += 1;
    }

    return {
      questionNo: index + 1,
      question: question.question,
      type,
      options: question.options,
      selected,
      correctAnswer: question.answer,
      explanation: question.explanation || "No explanation provided.",
      isCorrect
    };
  });

  const total = questions.length;
  const accuracy = total > 0 ? ((correct / total) * 100).toFixed(2) : "0.00";
  const timeTakenSeconds = Math.max(0, Math.floor((submittedAt - startedAt) / 1000));

  return {
    title,
    total,
    correct,
    wrong,
    attempted,
    score: `${correct}/${total}`,
    accuracy,
    timeTaken: formatSeconds(timeTakenSeconds),
    timeLeft: formatSeconds(Math.max(0, allottedSeconds - timeTakenSeconds)),
    submittedAt,
    review
  };
}

export function summaryItems(result) {
  return [
    { label: "Total Questions", value: result.total },
    { label: "Correct Answers", value: result.correct },
    { label: "Wrong Answers", value: result.wrong },
    { label: "Score", value: result.score },
    { label: "Accuracy %", value: `${result.accuracy}%` },
    { label: "Time Taken", value: result.timeTaken }
  ];
}
