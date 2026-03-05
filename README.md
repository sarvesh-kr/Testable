# Online Test Platform

A static, modular exam platform built with HTML, CSS, and vanilla JavaScript.

## Highlights

- Fully static deployment (GitHub Pages compatible)
- Exam -> test type -> mock/topic flow
- Topic-wise tests start immediately on topic click
- Data-driven architecture using JSON files
- Timer, question palette, mark for review, save/next, submit
- Result summary plus detailed explanation review
- localStorage-based progress and theme persistence
- Responsive UI for desktop/tablet/mobile

## Project Structure

```text
online-test-platform/
  index.html
  exam.html
  test-type.html
  mock-list.html
  topic-list.html
  test.html
  result.html
  robots.txt
  sitemap.xml
  favicon.svg
  css/
    styles.css
  js/
    app.js
    router.js
    examLoader.js
    questionEngine.js
    timer.js
    resultEngine.js
  data/
    exams.json
    topics.json
    mocks/
      mock1.json
      mock2.json
      mock3.json
    topics/
      *.json
  scripts/
    validate.ps1
    generators/
      topics/
        generate_*_250.ps1
      mocks/
        generate_mocks_from_topics.ps1
      legacy/
        regen_questions.ps1
```

## Run Locally

From the project root:

```powershell
python -m http.server 5500
```

Open: `http://localhost:5500/index.html`

Note: Use a local server because the app loads JSON via `fetch`.

## Deploy to GitHub Pages

1. Push this folder to a GitHub repository.
2. In repository settings, enable **Pages**.
3. Select branch `main` and root folder `/ (root)`.
4. Click deploy and open the published URL.

Expected Pages base URL for this repo:

`https://sarvesh-kr.github.io/Testable/`

## SEO and Crawl Setup

- `robots.txt` is included and points to `sitemap.xml`.
- `sitemap.xml` is preconfigured for `https://sarvesh-kr.github.io/Testable/`.
- Public listing pages use `index,follow`; transient session pages (`test.html`, `result.html`) use `noindex,nofollow`.

## Pre-Deploy Validation

Run this before pushing/deploying:

```powershell
.\scripts\validate.ps1
```

The script checks required files, JSON integrity, question schema, metadata consistency, internal links, and baseline SEO tags.

## Data Scalability

- Add exams in `data/exams.json`
- Add topics in `data/topics.json`
- Add topic question banks in `data/topics/*.json`
- Add/replace mock files in `data/mocks/*.json`

No JS code changes are required when adding new question files that follow the schema.

## Question JSON Schema

```json
{
  "id": 1,
  "question": "Sample question?",
  "options": ["A", "B", "C", "D"],
  "answer": 0,
  "explanation": "Why this is correct"
}
```

- `options` must contain exactly 4 strings.
- `answer` must be index `0..3`.

## Quality and Security Notes

- UI rendering avoids raw HTML injection for question and review text.
- Question files are validated at runtime before test rendering.
- Keep question data trusted and version controlled.
- Use HTTPS in production deployment.

## Regeneration Scripts

Topic and mock generation scripts are in `scripts/generators/`.

Examples:

```powershell
.\scripts\generators\mocks\generate_mocks_from_topics.ps1
.\scripts\generators\topics\generate_os_250.ps1
```

After generating data, run `.\scripts\validate.ps1` before committing.

