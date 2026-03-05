export class TestTimer {
  constructor({ durationSeconds, onTick, onExpire }) {
    this.remainingSeconds = durationSeconds;
    this.onTick = onTick;
    this.onExpire = onExpire;
    this.timerRef = null;
  }

  start() {
    if (this.timerRef) {
      return;
    }

    this.onTick(this.remainingSeconds);
    this.timerRef = window.setInterval(() => {
      const next = Math.max(0, this.remainingSeconds - 1);
      this.remainingSeconds = next;
      this.onTick(next);

      if (next <= 0) {
        this.stop();
        this.onExpire();
      }
    }, 1000);
  }

  setRemaining(seconds) {
    this.remainingSeconds = Math.max(0, seconds);
  }

  stop() {
    if (this.timerRef) {
      window.clearInterval(this.timerRef);
      this.timerRef = null;
    }
  }
}
