Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

function Shuffle($arr) { @($arr | Sort-Object { Get-Random }) }

$questions = @()
$id = 1

function Add-Mcq {
  param([string]$QuestionText,[string[]]$Options,[string]$Correct,[string]$Explanation)
  $answerIndex = [array]::IndexOf($Options, $Correct)
  if ($answerIndex -lt 0) { throw "Correct option missing: $QuestionText" }
  $script:questions += [ordered]@{ id=$script:id; question=$QuestionText; options=@($Options[0],$Options[1],$Options[2],$Options[3]); answer=$answerIndex; explanation=$Explanation }
  $script:id += 1
}

$facts = @(
  @{ term='Software Development Life Cycle'; definition='structured process from requirements to maintenance'; category='SDLC Models' },
  @{ term='Waterfall Model'; definition='sequential model with phase-wise completion'; category='SDLC Models' },
  @{ term='V-Model'; definition='testing-focused model mapping development phases to test levels'; category='SDLC Models' },
  @{ term='Spiral Model'; definition='risk-driven iterative model combining prototyping and planning'; category='SDLC Models' },
  @{ term='Incremental Model'; definition='model delivering software in small functional increments'; category='SDLC Models' },
  @{ term='Agile'; definition='iterative approach emphasizing collaboration and rapid feedback'; category='SDLC Models' },
  @{ term='Scrum'; definition='agile framework using sprints and defined team roles'; category='SDLC Models' },
  @{ term='Kanban'; definition='agile method visualizing work and limiting work-in-progress'; category='SDLC Models' },
  @{ term='Requirement Engineering'; definition='process of eliciting, analyzing, validating requirements'; category='Requirements' },
  @{ term='Functional Requirement'; definition='statement describing what system must do'; category='Requirements' },
  @{ term='Non-Functional Requirement'; definition='statement describing quality attributes and constraints'; category='Requirements' },
  @{ term='SRS'; definition='document specifying complete software requirements'; category='Requirements' },
  @{ term='Use Case'; definition='interaction scenario between actor and system'; category='Requirements' },
  @{ term='Feasibility Study'; definition='assessment of technical, economic, operational viability'; category='Requirements' },
  @{ term='Traceability Matrix'; definition='mapping between requirements and test cases/deliverables'; category='Requirements' },
  @{ term='Modularity'; definition='design principle dividing system into manageable components'; category='Design Principles' },
  @{ term='Cohesion'; definition='degree to which module elements belong together'; category='Design Principles' },
  @{ term='Coupling'; definition='degree of interdependence between modules'; category='Design Principles' },
  @{ term='Abstraction'; definition='focusing on essential behavior while hiding details'; category='Design Principles' },
  @{ term='Encapsulation'; definition='bundling data with methods and restricting direct access'; category='Design Principles' },
  @{ term='SOLID'; definition='set of object-oriented design principles for maintainable code'; category='Design Principles' },
  @{ term='Design Pattern'; definition='reusable solution template for common design problem'; category='Design Principles' },
  @{ term='UML'; definition='standard notation for visualizing software design artifacts'; category='Design Principles' },
  @{ term='Class Diagram'; definition='UML diagram showing classes, attributes, and relationships'; category='Design Principles' },
  @{ term='Sequence Diagram'; definition='UML diagram showing interaction order among objects'; category='Design Principles' },
  @{ term='Unit Testing'; definition='testing individual software units in isolation'; category='Testing' },
  @{ term='Integration Testing'; definition='testing interactions among integrated modules'; category='Testing' },
  @{ term='System Testing'; definition='testing complete integrated system against requirements'; category='Testing' },
  @{ term='Acceptance Testing'; definition='validation by user/business to confirm readiness'; category='Testing' },
  @{ term='Regression Testing'; definition='retesting to ensure changes do not break existing features'; category='Testing' },
  @{ term='Smoke Testing'; definition='quick test to verify critical build stability'; category='Testing' },
  @{ term='Sanity Testing'; definition='focused test to verify specific change works'; category='Testing' },
  @{ term='Black Box Testing'; definition='testing functionality without internal code knowledge'; category='Testing' },
  @{ term='White Box Testing'; definition='testing based on internal logic and code paths'; category='Testing' },
  @{ term='Boundary Value Analysis'; definition='test design technique using boundary input values'; category='Testing' },
  @{ term='Equivalence Partitioning'; definition='test design technique dividing inputs into valid/invalid classes'; category='Testing' },
  @{ term='Defect Density'; definition='number of defects per size unit of software'; category='Quality Metrics' },
  @{ term='Cyclomatic Complexity'; definition='metric indicating number of independent code paths'; category='Quality Metrics' },
  @{ term='Code Coverage'; definition='percentage of code executed by tests'; category='Quality Metrics' },
  @{ term='MTTR'; definition='mean time to restore service after failure'; category='Quality Metrics' },
  @{ term='MTBF'; definition='mean time between two system failures'; category='Quality Metrics' },
  @{ term='Configuration Management'; definition='control of software versions and changes'; category='DevOps and Process' },
  @{ term='Version Control'; definition='system tracking changes to source code over time'; category='DevOps and Process' },
  @{ term='Continuous Integration'; definition='practice of frequent code merges with automated builds'; category='DevOps and Process' },
  @{ term='Continuous Delivery'; definition='practice ensuring software is releasable at any time'; category='DevOps and Process' },
  @{ term='Continuous Deployment'; definition='automatic deployment to production after pipeline success'; category='DevOps and Process' },
  @{ term='Code Review'; definition='systematic examination of source code by peers'; category='DevOps and Process' },
  @{ term='Technical Debt'; definition='future cost caused by short-term design compromises'; category='DevOps and Process' },
  @{ term='Risk Management'; definition='identifying and mitigating project uncertainties'; category='Project Management' },
  @{ term='Critical Path'; definition='longest dependent task sequence determining project duration'; category='Project Management' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Software Engineering concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which software engineering area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct software engineering term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A project requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/software_engineering.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


