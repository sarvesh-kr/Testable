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
  @{ term='Variable'; definition='named storage location for data value'; category='Programming Basics' },
  @{ term='Data Type'; definition='classification defining kind of value and operations'; category='Programming Basics' },
  @{ term='Integer'; definition='whole number data type without fractional part'; category='Programming Basics' },
  @{ term='Boolean'; definition='data type representing true or false'; category='Programming Basics' },
  @{ term='String'; definition='sequence of characters representing text'; category='Programming Basics' },
  @{ term='Array'; definition='indexed collection storing multiple values of same type'; category='Programming Basics' },
  @{ term='Function'; definition='reusable block of code performing specific task'; category='Programming Basics' },
  @{ term='Parameter'; definition='input variable accepted by function definition'; category='Programming Basics' },
  @{ term='Return Value'; definition='output produced by function after execution'; category='Programming Basics' },
  @{ term='Loop'; definition='control structure that repeats a block while condition holds'; category='Programming Basics' },
  @{ term='Recursion'; definition='technique where function calls itself to solve problem'; category='Programming Basics' },
  @{ term='Conditional Statement'; definition='branching construct selecting path based on condition'; category='Programming Basics' },
  @{ term='Compilation'; definition='translation of source code to machine-readable form'; category='Programming Basics' },
  @{ term='Interpreter'; definition='program executing source code line by line'; category='Programming Basics' },
  @{ term='Runtime Error'; definition='error occurring during program execution'; category='Programming Basics' },
  @{ term='Class'; definition='blueprint defining attributes and methods of objects'; category='Object-Oriented Programming' },
  @{ term='Object'; definition='instance of a class with state and behavior'; category='Object-Oriented Programming' },
  @{ term='Encapsulation'; definition='bundling data and methods with access control'; category='Object-Oriented Programming' },
  @{ term='Inheritance'; definition='mechanism deriving new class from existing class'; category='Object-Oriented Programming' },
  @{ term='Polymorphism'; definition='ability to use same interface for different underlying forms'; category='Object-Oriented Programming' },
  @{ term='Abstraction'; definition='hiding implementation details while exposing essentials'; category='Object-Oriented Programming' },
  @{ term='Interface'; definition='contract specifying methods without implementation details'; category='Object-Oriented Programming' },
  @{ term='Method Overloading'; definition='same method name with different parameter signatures'; category='Object-Oriented Programming' },
  @{ term='Method Overriding'; definition='subclass redefining inherited method behavior'; category='Object-Oriented Programming' },
  @{ term='Constructor'; definition='special method initializing object state on creation'; category='Object-Oriented Programming' },
  @{ term='Exception'; definition='abnormal event disrupting normal program flow'; category='Error Handling' },
  @{ term='Try-Catch'; definition='structure for handling exceptions gracefully'; category='Error Handling' },
  @{ term='Finally Block'; definition='code block executed regardless of exception outcome'; category='Error Handling' },
  @{ term='Null Pointer'; definition='reference accessing object when reference is null'; category='Error Handling' },
  @{ term='Input Validation'; definition='checking user input against expected format/rules'; category='Error Handling' },
  @{ term='Unit Test'; definition='automated test validating smallest code units'; category='Testing and Quality' },
  @{ term='Integration Test'; definition='test verifying interaction between combined modules'; category='Testing and Quality' },
  @{ term='Regression Test'; definition='test ensuring changes did not break existing features'; category='Testing and Quality' },
  @{ term='Code Coverage'; definition='metric showing percentage of code tested'; category='Testing and Quality' },
  @{ term='Debugging'; definition='process of identifying and fixing defects'; category='Testing and Quality' },
  @{ term='Version Control'; definition='system for tracking changes in source code'; category='Development Workflow' },
  @{ term='Git Commit'; definition='recorded snapshot of staged source code changes'; category='Development Workflow' },
  @{ term='Branch'; definition='parallel line of development in version control'; category='Development Workflow' },
  @{ term='Merge'; definition='operation combining changes from different branches'; category='Development Workflow' },
  @{ term='Pull Request'; definition='proposal to review and merge code changes'; category='Development Workflow' },
  @{ term='CI Pipeline'; definition='automated workflow for build and test on code changes'; category='Development Workflow' },
  @{ term='Code Review'; definition='peer examination of code for quality and defects'; category='Development Workflow' },
  @{ term='Refactoring'; definition='improving internal code structure without changing behavior'; category='Development Workflow' },
  @{ term='Time Complexity'; definition='growth rate of algorithm runtime with input size'; category='Algorithmic Thinking' },
  @{ term='Space Complexity'; definition='growth rate of memory use with input size'; category='Algorithmic Thinking' },
  @{ term='Big O Notation'; definition='asymptotic upper bound representation of complexity'; category='Algorithmic Thinking' },
  @{ term='Linear Search'; definition='algorithm scanning elements sequentially to find target'; category='Algorithmic Thinking' },
  @{ term='Binary Search'; definition='algorithm finding element in sorted array by halving range'; category='Algorithmic Thinking' },
  @{ term='Hash Table'; definition='data structure mapping keys to values for fast lookup'; category='Algorithmic Thinking' },
  @{ term='Stack'; definition='LIFO data structure supporting push and pop'; category='Algorithmic Thinking' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Programming concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which programming area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct programming term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT coding requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/programming_software_development.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


