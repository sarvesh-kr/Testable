import { formatSeconds } from "./app.js";

export function buildResult({ questions, answers, startedAt, submittedAt, allottedSeconds, title }) {
  let correct = 0;
  let wrong = 0;

  const review = questions.map((question, index) => {
    const selected = answers[index];
    const isCorrect = selected === question.answer;

    if (selected !== undefined && isCorrect) {
      correct += 1;
    }

    if (selected !== undefined && !isCorrect) {
      wrong += 1;
    }

    return {
      questionNo: index + 1,
      question: question.question,
      options: question.options,
      selected,
      correctAnswer: question.answer,
      explanation: question.explanation,
      isCorrect
    };
  });

  const total = questions.length;
  const attempted = Object.keys(answers).length;
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
