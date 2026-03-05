import { fetchJSON } from "./app.js";

export async function loadExams() {
  const data = await fetchJSON("./data/exams.json");
  return data.exams || [];
}

export async function loadTopics(examId) {
  const data = await fetchJSON("./data/topics.json");
  return (data.topics || []).filter((topic) => topic.examId === examId);
}

export async function getExamById(examId) {
  const exams = await loadExams();
  return exams.find((exam) => exam.id === examId) || null;
}

export async function loadQuestionSet(path) {
  const data = await fetchJSON(path);
  return data.questions || [];
}
