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
  @{ term='Core Banking System'; definition='centralized platform processing banking transactions across branches in real time'; category='Core Banking Fundamentals' },
  @{ term='CBS Parameterization'; definition='configuring product, interest, and rule settings in core banking'; category='Core Banking Fundamentals' },
  @{ term='Customer Information File'; definition='unique customer master profile used across banking products'; category='Core Banking Fundamentals' },
  @{ term='CASA'; definition='current and savings account product category'; category='Core Banking Fundamentals' },
  @{ term='General Ledger'; definition='master accounting book recording all financial entries'; category='Core Banking Fundamentals' },
  @{ term='End of Day Processing'; definition='daily batch operations for closure, interest, and reconciliation'; category='Core Banking Fundamentals' },
  @{ term='Start of Day Processing'; definition='opening day activities enabling transaction processing'; category='Core Banking Fundamentals' },
  @{ term='Maker Checker'; definition='dual-control workflow where one user creates and another authorizes'; category='Core Banking Fundamentals' },
  @{ term='Straight Through Processing'; definition='automated transaction flow without manual intervention'; category='Core Banking Fundamentals' },
  @{ term='Reconciliation'; definition='matching records between systems to identify discrepancies'; category='Core Banking Fundamentals' },

  @{ term='KYC'; definition='customer due diligence process for identity and risk verification'; category='Compliance and Risk' },
  @{ term='AML'; definition='controls and monitoring to prevent money laundering'; category='Compliance and Risk' },
  @{ term='CFT'; definition='controls designed to prevent financing of terrorism'; category='Compliance and Risk' },
  @{ term='Sanctions Screening'; definition='checking customers and transactions against sanctions lists'; category='Compliance and Risk' },
  @{ term='PEP Screening'; definition='identifying politically exposed persons for enhanced due diligence'; category='Compliance and Risk' },
  @{ term='Transaction Monitoring'; definition='surveillance of account activity for suspicious behavior'; category='Compliance and Risk' },
  @{ term='STR'; definition='report filed for suspicious transaction activity'; category='Compliance and Risk' },
  @{ term='CTR'; definition='report filed for transactions above regulatory cash threshold'; category='Compliance and Risk' },
  @{ term='Risk Rating'; definition='classification of customer risk based on profile and behavior'; category='Compliance and Risk' },
  @{ term='Audit Trail'; definition='tamper-evident log of user and system actions'; category='Compliance and Risk' },

  @{ term='Internet Banking'; definition='banking services accessed via web browser'; category='Digital Banking Channels' },
  @{ term='Mobile Banking'; definition='banking services delivered through smartphone application'; category='Digital Banking Channels' },
  @{ term='SMS Banking'; definition='banking alerts and commands via text messaging'; category='Digital Banking Channels' },
  @{ term='USSD Banking'; definition='session-based banking using telecom short codes'; category='Digital Banking Channels' },
  @{ term='Omnichannel Banking'; definition='unified customer experience across multiple service channels'; category='Digital Banking Channels' },
  @{ term='Digital Onboarding'; definition='remote account opening using digital verification workflows'; category='Digital Banking Channels' },
  @{ term='eKYC'; definition='electronic KYC verification using digital identity sources'; category='Digital Banking Channels' },
  @{ term='Video KYC'; definition='live video-based customer due diligence process'; category='Digital Banking Channels' },
  @{ term='Customer Journey'; definition='end-to-end sequence of customer interactions with bank'; category='Digital Banking Channels' },
  @{ term='Personalization'; definition='tailoring digital experience based on customer behavior and profile'; category='Digital Banking Channels' },

  @{ term='Payment Gateway'; definition='service authorizing and routing online payment transactions'; category='Payments Integration' },
  @{ term='UPI Integration'; definition='connectivity enabling instant bank-to-bank transfers via UPI'; category='Payments Integration' },
  @{ term='IMPS Integration'; definition='real-time funds transfer integration through IMPS rail'; category='Payments Integration' },
  @{ term='NEFT Integration'; definition='batch-based electronic fund transfer integration'; category='Payments Integration' },
  @{ term='RTGS Integration'; definition='high-value real-time gross settlement integration'; category='Payments Integration' },
  @{ term='API Banking'; definition='exposing banking services securely through APIs'; category='Payments Integration' },
  @{ term='Open Banking'; definition='regulated secure sharing of banking data via APIs'; category='Payments Integration' },
  @{ term='ISO 20022'; definition='financial messaging standard for interoperable payments'; category='Payments Integration' },
  @{ term='SWIFT Messaging'; definition='international secure financial messaging network'; category='Payments Integration' },
  @{ term='Nostro Reconciliation'; definition='matching entries in foreign currency correspondent accounts'; category='Payments Integration' },

  @{ term='Multi-Factor Authentication'; definition='authentication requiring more than one independent factor'; category='Security and Operations' },
  @{ term='Device Binding'; definition='linking digital banking access to registered customer device'; category='Security and Operations' },
  @{ term='Fraud Detection Engine'; definition='rule and model-based system detecting suspicious activity'; category='Security and Operations' },
  @{ term='Velocity Check'; definition='control evaluating transaction frequency and amount patterns'; category='Security and Operations' },
  @{ term='Transaction Limit Management'; definition='configuring permissible transfer and withdrawal thresholds'; category='Security and Operations' },
  @{ term='Role-Based Access Control'; definition='access model assigning permissions according to roles'; category='Security and Operations' },
  @{ term='Business Continuity'; definition='capability to continue critical services during disruption'; category='Security and Operations' },
  @{ term='Disaster Recovery'; definition='process and infrastructure for restoring systems after outage'; category='Security and Operations' },
  @{ term='RTO'; definition='maximum acceptable time to restore service after failure'; category='Security and Operations' },
  @{ term='RPO'; definition='maximum acceptable data loss interval during disruption'; category='Security and Operations' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which core/digital banking concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which core banking area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct core banking term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/core_banking_digital_banking.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


