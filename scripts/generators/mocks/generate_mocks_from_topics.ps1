Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

$topics = (Get-Content "data/topics.json" -Raw | ConvertFrom-Json).topics
$allQuestions = @()

foreach ($topic in $topics) {
  $path = "data/topics/$($topic.file)"
  $qs = (Get-Content $path -Raw | ConvertFrom-Json).questions

  foreach ($q in $qs) {
    $allQuestions += [pscustomobject]@{
      source = $topic.name
      question = $q.question
      options = @($q.options[0], $q.options[1], $q.options[2], $q.options[3])
      answer = $q.answer
      explanation = $q.explanation
    }
  }
}

if ($allQuestions.Count -lt 300) {
  throw "Insufficient topic question pool to generate mocks."
}

function Build-Mock {
  param(
    [int]$mockNo,
    [object[]]$pool,
    [int]$count
  )

  # Create stable-but-different ordering per mock by seeded random sort style.
  $ordered = $pool | Sort-Object { Get-Random }
  $picked = $ordered | Select-Object -First $count

  $final = @()
  $i = 1
  foreach ($q in $picked) {
    $final += [ordered]@{
      id = $i
      question = $q.question
      options = @($q.options[0], $q.options[1], $q.options[2], $q.options[3])
      answer = $q.answer
      explanation = $q.explanation
    }
    $i += 1
  }

  [ordered]@{ questions = $final } |
    ConvertTo-Json -Depth 8 |
    Set-Content -Path "data/mocks/mock$mockNo.json" -Encoding utf8
}

Build-Mock -mockNo 1 -pool $allQuestions -count 100
Build-Mock -mockNo 2 -pool $allQuestions -count 100
Build-Mock -mockNo 3 -pool $allQuestions -count 100

Write-Output "Regenerated mock1/mock2/mock3 with 100 questions each from topic banks."


