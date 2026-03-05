Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

function Shuffle($arr) {
  return @($arr | Sort-Object { Get-Random })
}

$questions = @()
$id = 1

function Add-Mcq {
  param(
    [string]$QuestionText,
    [string[]]$Options,
    [string]$Correct,
    [string]$Explanation
  )

  $answerIndex = [array]::IndexOf($Options, $Correct)
  if ($answerIndex -lt 0) {
    throw "Correct option not found for question: $QuestionText"
  }

  $script:questions += [ordered]@{
    id = $script:id
    question = $QuestionText
    options = @($Options[0], $Options[1], $Options[2], $Options[3])
    answer = $answerIndex
    explanation = $Explanation
  }

  $script:id += 1
}

$facts = @(
  @{ term='DBMS'; definition='software for creating and managing structured databases'; category='Fundamentals' },
  @{ term='RDBMS'; definition='database system based on relational model and tables'; category='Fundamentals' },
  @{ term='Schema'; definition='logical design describing structure of database objects'; category='Fundamentals' },
  @{ term='Instance'; definition='actual data stored in database at a specific time'; category='Fundamentals' },
  @{ term='Data Independence'; definition='ability to change schema at one level without affecting higher level'; category='Fundamentals' },

  @{ term='Primary Key'; definition='attribute that uniquely identifies each row in a table'; category='Keys and Constraints' },
  @{ term='Candidate Key'; definition='minimal attribute set that can uniquely identify tuples'; category='Keys and Constraints' },
  @{ term='Super Key'; definition='attribute set that uniquely identifies each row, minimality not required'; category='Keys and Constraints' },
  @{ term='Foreign Key'; definition='attribute referencing primary key of another table'; category='Keys and Constraints' },
  @{ term='Composite Key'; definition='key formed by more than one column'; category='Keys and Constraints' },
  @{ term='Unique Constraint'; definition='constraint ensuring no duplicate values in specified column set'; category='Keys and Constraints' },
  @{ term='NOT NULL Constraint'; definition='constraint preventing null values in a column'; category='Keys and Constraints' },
  @{ term='CHECK Constraint'; definition='constraint enforcing custom Boolean condition on data'; category='Keys and Constraints' },
  @{ term='Referential Integrity'; definition='consistency rule ensuring foreign keys match referenced rows'; category='Keys and Constraints' },
  @{ term='Entity Integrity'; definition='rule requiring primary key to be unique and non-null'; category='Keys and Constraints' },

  @{ term='First Normal Form'; definition='normal form where attributes contain atomic values only'; category='Normalization' },
  @{ term='Second Normal Form'; definition='normal form removing partial dependency on composite key'; category='Normalization' },
  @{ term='Third Normal Form'; definition='normal form removing transitive dependency on non-key attributes'; category='Normalization' },
  @{ term='BCNF'; definition='normal form requiring every determinant to be a candidate key'; category='Normalization' },
  @{ term='Denormalization'; definition='intentional introduction of redundancy to improve read performance'; category='Normalization' },

  @{ term='SELECT'; definition='SQL command used to retrieve data from tables'; category='SQL Operations' },
  @{ term='INSERT'; definition='SQL command used to add new rows into a table'; category='SQL Operations' },
  @{ term='UPDATE'; definition='SQL command used to modify existing rows'; category='SQL Operations' },
  @{ term='DELETE'; definition='SQL command used to remove selected rows'; category='SQL Operations' },
  @{ term='TRUNCATE'; definition='DDL-like command removing all table rows quickly'; category='SQL Operations' },
  @{ term='ALTER'; definition='command used to modify table structure'; category='SQL Operations' },
  @{ term='DROP'; definition='command used to remove database object permanently'; category='SQL Operations' },
  @{ term='CREATE'; definition='command used to create database objects like table or index'; category='SQL Operations' },
  @{ term='GROUP BY'; definition='clause used to aggregate rows by column values'; category='SQL Operations' },
  @{ term='HAVING'; definition='clause used to filter grouped aggregate results'; category='SQL Operations' },

  @{ term='INNER JOIN'; definition='join returning rows with matching values in both tables'; category='Joins and Queries' },
  @{ term='LEFT JOIN'; definition='join returning all rows from left table and matches from right'; category='Joins and Queries' },
  @{ term='RIGHT JOIN'; definition='join returning all rows from right table and matches from left'; category='Joins and Queries' },
  @{ term='FULL OUTER JOIN'; definition='join returning all rows when match exists in either table'; category='Joins and Queries' },
  @{ term='CROSS JOIN'; definition='join producing Cartesian product of two tables'; category='Joins and Queries' },
  @{ term='Subquery'; definition='query nested inside another SQL query'; category='Joins and Queries' },
  @{ term='View'; definition='virtual table based on a stored SQL query'; category='Joins and Queries' },
  @{ term='Index'; definition='data structure improving speed of data retrieval operations'; category='Joins and Queries' },
  @{ term='Clustered Index'; definition='index that determines physical storage order of table rows'; category='Joins and Queries' },
  @{ term='Non-Clustered Index'; definition='separate index structure containing pointers to data rows'; category='Joins and Queries' },

  @{ term='Transaction'; definition='logical unit of work executed completely or not at all'; category='Transactions and Concurrency' },
  @{ term='Atomicity'; definition='ACID property ensuring all operations in transaction succeed or rollback'; category='Transactions and Concurrency' },
  @{ term='Consistency'; definition='ACID property preserving valid database rules before and after transaction'; category='Transactions and Concurrency' },
  @{ term='Isolation'; definition='ACID property controlling visibility of concurrent transaction changes'; category='Transactions and Concurrency' },
  @{ term='Durability'; definition='ACID property ensuring committed data survives system failures'; category='Transactions and Concurrency' },
  @{ term='COMMIT'; definition='statement that permanently saves transaction changes'; category='Transactions and Concurrency' },
  @{ term='ROLLBACK'; definition='statement that undoes uncommitted transaction changes'; category='Transactions and Concurrency' },
  @{ term='Deadlock'; definition='situation where transactions wait indefinitely for each other resources'; category='Transactions and Concurrency' },
  @{ term='Shared Lock'; definition='lock allowing read access by multiple transactions'; category='Transactions and Concurrency' },
  @{ term='Exclusive Lock'; definition='lock that prevents other transactions from reading or writing data'; category='Transactions and Concurrency' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']
  $definition = $fact['definition']
  $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which DBMS concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term' in DBMS context?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' is primarily associated with which DBMS area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category in DBMS preparation."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) {
    $pairs += "$($wf['term']) -> $definition"
  }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct DBMS term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A bank IT database requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) {
  throw "Expected 250 questions, generated $($questions.Count)."
}

$target = "data/topics/database_management_system.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


