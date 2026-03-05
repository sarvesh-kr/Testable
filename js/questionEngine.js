import { buildAttemptProgressKey, getFromStorage, saveToStorage } from "./app.js";

export function createInitialState(attempt, questions) {
  const total = questions.length;
  return {
    attemptId: attempt.attemptId,
    currentIndex: 0,
    answers: {},
    reviewMap: {},
    visited: { 0: true },
    remainingSeconds: attempt.durationMinutes * 60,
    total,
    startedAt: Date.now()
  };
}

export function loadOrCreateState(attempt, questions) {
  const progressKey = buildAttemptProgressKey(attempt.attemptId);
  const saved = getFromStorage(progressKey, null);

  // Reinitialize state when question count changes to avoid stale progress mismatch.
  if (!saved || saved.total !== questions.length) {
    const initial = createInitialState(attempt, questions);
    persistState(initial);
    return initial;
  }

  return saved;
}

export function persistState(state) {
  saveToStorage(buildAttemptProgressKey(state.attemptId), state);
}

export function setAnswer(state, index, answerIndex) {
  state.answers[index] = answerIndex;
  state.visited[index] = true;
}

export function clearAnswer(state, index) {
  delete state.answers[index];
  state.visited[index] = true;
}

export function markReview(state, index) {
  state.reviewMap[index] = true;
  state.visited[index] = true;
}

export function moveTo(state, index) {
  const bounded = Math.min(Math.max(index, 0), state.total - 1);
  state.currentIndex = bounded;
  state.visited[bounded] = true;
}

export function getQuestionStatus(state, index) {
  const visited = Boolean(state.visited[index]);
  const answered = state.answers[index] !== undefined;
  const review = Boolean(state.reviewMap[index]);

  // Palette state priority follows common exam UI behavior.
  if (!visited) {
    return "not-visited";
  }

  if (review) {
    return "review";
  }

  if (answered) {
    return "answered";
  }

  return "not-answered";
}
