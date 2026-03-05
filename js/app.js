const STORAGE_KEYS = {
  selectedExam: "otp_selected_exam",
  currentAttempt: "otp_current_attempt",
  lastResult: "otp_last_result",
  theme: "otp_theme"
};

const jsonCache = new Map();

export function getStorageKey(key) {
  return STORAGE_KEYS[key] ?? key;
}

export function getFromStorage(key, fallback = null) {
  let raw = null;
  try {
    raw = localStorage.getItem(getStorageKey(key));
  } catch {
    return fallback;
  }

  if (!raw) {
    return fallback;
  }

  try {
    return JSON.parse(raw);
  } catch {
    return fallback;
  }
}

export function saveToStorage(key, value) {
  try {
    localStorage.setItem(getStorageKey(key), JSON.stringify(value));
  } catch {
    // Ignore persistence failures (quota/private mode) and continue app flow.
  }
}

export function removeFromStorage(key) {
  try {
    localStorage.removeItem(getStorageKey(key));
  } catch {
    // Ignore storage access errors.
  }
}

export function getQueryParam(name) {
  return new URLSearchParams(window.location.search).get(name);
}

export function navigate(path) {
  window.location.href = path;
}

export function formatSeconds(totalSeconds) {
  const safe = Math.max(0, totalSeconds);
  const hours = String(Math.floor(safe / 3600)).padStart(2, "0");
  const minutes = String(Math.floor((safe % 3600) / 60)).padStart(2, "0");
  const seconds = String(safe % 60).padStart(2, "0");
  return `${hours}:${minutes}:${seconds}`;
}

export async function fetchJSON(path) {
  if (jsonCache.has(path)) {
    return jsonCache.get(path);
  }

  const controller = new AbortController();
  const timeoutId = window.setTimeout(() => controller.abort(), 10000);

  let response;
  try {
    response = await fetch(path, {
      cache: "no-store",
      signal: controller.signal,
      headers: {
        Accept: "application/json"
      }
    });
  } catch (error) {
    if (error && error.name === "AbortError") {
      throw new Error(`Request timed out while loading ${path}`);
    }
    throw error;
  } finally {
    window.clearTimeout(timeoutId);
  }

  if (!response.ok) {
    throw new Error(`Failed to load ${path} (HTTP ${response.status})`);
  }

  const payload = await response.json();
  jsonCache.set(path, payload);
  return payload;
}

export function setupThemeToggle() {
  let saved = "light";
  try {
    saved = localStorage.getItem(getStorageKey("theme")) || "light";
  } catch {
    saved = "light";
  }

  document.body.dataset.theme = saved;

  const themeToggle = document.getElementById("theme-toggle");
  if (!themeToggle) {
    return;
  }

  themeToggle.textContent = saved === "dark" ? "Light Mode" : "Dark Mode";
  themeToggle.addEventListener("click", () => {
    const current = document.body.dataset.theme === "dark" ? "dark" : "light";
    const next = current === "dark" ? "light" : "dark";
    document.body.dataset.theme = next;
    try {
      localStorage.setItem(getStorageKey("theme"), next);
    } catch {
      // Continue even if theme persistence is unavailable.
    }
    themeToggle.textContent = next === "dark" ? "Light Mode" : "Dark Mode";
  });
}

export function buildAttemptProgressKey(attemptId) {
  return `otp_progress_${attemptId}`;
}

export function createEl(tag, className = "", text = "") {
  const node = document.createElement(tag);
  if (className) {
    node.className = className;
  }
  if (text) {
    node.textContent = text;
  }
  return node;
}
