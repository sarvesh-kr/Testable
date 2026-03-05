$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot ".."))

$issues = @()
$warnings = @()

function Add-Issue {
  param([string]$Message)
  $script:issues += $Message
}

function Add-Warning {
  param([string]$Message)
  $script:warnings += $Message
}

function Test-RequiredFile {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    Add-Issue "Missing required file: $Path"
  }
}

# Core site and SEO assets.
$requiredFiles = @(
  "index.html",
  "exam.html",
  "test-type.html",
  "mock-list.html",
  "topic-list.html",
  "test.html",
  "result.html",
  "css/styles.css",
  "js/app.js",
  "js/router.js",
  "js/examLoader.js",
  "js/questionEngine.js",
  "js/timer.js",
  "js/resultEngine.js",
  "data/exams.json",
  "data/topics.json",
  "robots.txt",
  "sitemap.xml",
  "favicon.svg"
)
$requiredFiles | ForEach-Object { Test-RequiredFile $_ }

# Validate data files.
$examsData = $null
$topicsMeta = $null

try {
  $examsData = Get-Content "data/exams.json" -Raw | ConvertFrom-Json
} catch {
  Add-Issue "Invalid JSON: data/exams.json"
}

try {
  $topicsMeta = Get-Content "data/topics.json" -Raw | ConvertFrom-Json
} catch {
  Add-Issue "Invalid JSON: data/topics.json"
}

if ($examsData -and $topicsMeta) {
  if (-not $examsData.exams -or $examsData.exams.Count -lt 1) {
    Add-Issue "No exams found in data/exams.json"
  }

  $examIds = @($examsData.exams | ForEach-Object { $_.id })

  foreach ($topic in $topicsMeta.topics) {
    if ($examIds -notcontains $topic.examId) {
      Add-Issue "Topic examId mismatch: $($topic.id) -> $($topic.examId)"
    }

    $topicPath = "data/topics/$($topic.file)"
    if (-not (Test-Path $topicPath)) {
      Add-Issue "Missing topic file: $topicPath"
      continue
    }

    $topicJson = $null
    try {
      $topicJson = Get-Content $topicPath -Raw | ConvertFrom-Json
    } catch {
      Add-Issue "Invalid JSON: $topicPath"
      continue
    }

    $questions = @($topicJson.questions)
    $bad = @(
      $questions | Where-Object {
        -not $_ -or
        [string]::IsNullOrWhiteSpace($_.question) -or
        [string]::IsNullOrWhiteSpace($_.explanation) -or
        -not $_.options -or
        $_.options.Count -ne 4 -or
        ($_.options | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0 -or
        $_.answer -lt 0 -or
        $_.answer -gt 3
      }
    )

    if ($questions.Count -ne $topic.questionCount) {
      Add-Issue "Topic count mismatch: $($topic.id) file=$($questions.Count) meta=$($topic.questionCount)"
    }

    if ($bad.Count -gt 0) {
      Add-Issue "Invalid topic questions in $($topic.id): $($bad.Count)"
    }
  }

  foreach ($exam in $examsData.exams) {
    foreach ($mock in $exam.mockTests) {
      $mockPath = "data/mocks/$($mock.file)"
      if (-not (Test-Path $mockPath)) {
        Add-Issue "Missing mock file: $mockPath"
        continue
      }

      $mockJson = $null
      try {
        $mockJson = Get-Content $mockPath -Raw | ConvertFrom-Json
      } catch {
        Add-Issue "Invalid JSON: $mockPath"
        continue
      }

      $mockQuestions = @($mockJson.questions)
      $mockBad = @(
        $mockQuestions | Where-Object {
          -not $_ -or
          [string]::IsNullOrWhiteSpace($_.question) -or
          [string]::IsNullOrWhiteSpace($_.explanation) -or
          -not $_.options -or
          $_.options.Count -ne 4 -or
          ($_.options | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0 -or
          $_.answer -lt 0 -or
          $_.answer -gt 3
        }
      )

      if ($mockQuestions.Count -ne $mock.questionCount) {
        Add-Issue "Mock count mismatch: $($mock.id) file=$($mockQuestions.Count) meta=$($mock.questionCount)"
      }

      if ($mockBad.Count -gt 0) {
        Add-Issue "Invalid mock questions in $($mock.id): $($mockBad.Count)"
      }
    }
  }
}

# Validate internal local references in HTML pages.
$htmlFiles = Get-ChildItem -File -Path . -Filter "*.html"
foreach ($htmlFile in $htmlFiles) {
  $content = Get-Content $htmlFile.FullName -Raw
  $matches = [regex]::Matches($content, '(?:href|src)="([^"]+)"')
  foreach ($match in $matches) {
    $ref = $match.Groups[1].Value
    if ($ref -match "^(https?:|mailto:|#|javascript:)") {
      continue
    }

    $resolved = Join-Path $PWD $ref
    if (-not (Test-Path $resolved)) {
      Add-Issue "$($htmlFile.Name): broken local reference -> $ref"
    }
  }
}

# Basic SEO checks.
foreach ($htmlFile in $htmlFiles) {
  $content = Get-Content $htmlFile.FullName -Raw
  if ($content -notmatch '<meta\s+name="description"') {
    Add-Issue "$($htmlFile.Name): missing meta description"
  }
  if ($content -notmatch '<link\s+rel="canonical"') {
    Add-Issue "$($htmlFile.Name): missing canonical link"
  }
  if ($content -notmatch 'Content-Security-Policy') {
    Add-Issue "$($htmlFile.Name): missing CSP meta"
  }
}

$sitemap = Get-Content "sitemap.xml" -Raw
if ($sitemap -match "example\.com") {
  Add-Warning "sitemap.xml still contains example.com placeholder"
}

if ($sitemap -notmatch '<loc>https://[^<]+</loc>') {
  Add-Issue "sitemap.xml contains malformed <loc> URL entries"
}

$robots = Get-Content "robots.txt" -Raw
if ($robots -notmatch 'Sitemap:\s+https://\S+/sitemap\.xml') {
  Add-Issue "robots.txt has missing or malformed Sitemap URL"
}

Write-Output "validation_issues=$($issues.Count)"
Write-Output "validation_warnings=$($warnings.Count)"

if ($warnings.Count -gt 0) {
  Write-Output "--- Warnings ---"
  $warnings | ForEach-Object { Write-Output $_ }
}

if ($issues.Count -gt 0) {
  Write-Output "--- Issues ---"
  $issues | Select-Object -First 100 | ForEach-Object { Write-Output $_ }
  exit 1
}

Write-Output "Validation passed."
exit 0
