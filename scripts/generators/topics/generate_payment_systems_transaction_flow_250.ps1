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
  @{ term='Payment System'; definition='framework enabling transfer of monetary value between payer and payee'; category='Payment Fundamentals' },
  @{ term='Payer'; definition='person or entity initiating payment transaction'; category='Payment Fundamentals' },
  @{ term='Payee'; definition='person or entity receiving payment funds'; category='Payment Fundamentals' },
  @{ term='Issuer Bank'; definition='bank that issues account/card used by payer'; category='Payment Fundamentals' },
  @{ term='Acquirer Bank'; definition='bank that services merchant and accepts payment requests'; category='Payment Fundamentals' },
  @{ term='Payment Gateway'; definition='service that securely routes online payment details'; category='Payment Fundamentals' },
  @{ term='Payment Processor'; definition='entity processing transaction authorization and routing'; category='Payment Fundamentals' },
  @{ term='Switch'; definition='network component routing transactions to destination institutions'; category='Payment Fundamentals' },
  @{ term='Authorization'; definition='stage where issuer validates and approves transaction'; category='Payment Fundamentals' },
  @{ term='Settlement'; definition='final transfer of funds between participating institutions'; category='Payment Fundamentals' },

  @{ term='UPI'; definition='instant interbank transfer system using virtual payment identifiers'; category='Indian Payment Rails' },
  @{ term='IMPS'; definition='immediate funds transfer service available 24x7'; category='Indian Payment Rails' },
  @{ term='NEFT'; definition='electronic fund transfer processed in batches round the clock'; category='Indian Payment Rails' },
  @{ term='RTGS'; definition='real-time gross settlement for high-value transfers'; category='Indian Payment Rails' },
  @{ term='NACH'; definition='electronic clearing system for bulk recurring transactions'; category='Indian Payment Rails' },
  @{ term='AEPS'; definition='Aadhaar enabled payment system using biometric authentication'; category='Indian Payment Rails' },
  @{ term='BBPS'; definition='interoperable bill payment ecosystem under NPCI'; category='Indian Payment Rails' },
  @{ term='FASTag'; definition='RFID-based electronic toll collection mechanism'; category='Indian Payment Rails' },
  @{ term='RuPay'; definition='domestic card payment network in India'; category='Indian Payment Rails' },
  @{ term='NPCI'; definition='umbrella organization operating retail payment systems in India'; category='Indian Payment Rails' },

  @{ term='Clearing'; definition='process of exchange and reconciliation of payment instructions'; category='Transaction Lifecycle' },
  @{ term='Posting'; definition='recording transaction entries in customer and GL accounts'; category='Transaction Lifecycle' },
  @{ term='Reversal'; definition='operation to negate a previously processed transaction'; category='Transaction Lifecycle' },
  @{ term='Chargeback'; definition='card dispute process returning funds to customer'; category='Transaction Lifecycle' },
  @{ term='Refund'; definition='merchant-initiated return of funds to customer'; category='Transaction Lifecycle' },
  @{ term='Reconciliation'; definition='matching transaction records across systems for accuracy'; category='Transaction Lifecycle' },
  @{ term='STP'; definition='straight through processing without manual intervention'; category='Transaction Lifecycle' },
  @{ term='Batch Processing'; definition='processing grouped transactions at scheduled intervals'; category='Transaction Lifecycle' },
  @{ term='Real-Time Processing'; definition='immediate processing and response for each transaction'; category='Transaction Lifecycle' },
  @{ term='Cut-off Time'; definition='time limit after which transaction goes to next cycle'; category='Transaction Lifecycle' },

  @{ term='IFSC'; definition='bank branch code used for routing electronic transfers'; category='Identifiers and Messaging' },
  @{ term='Account Number'; definition='unique number identifying customer account in bank'; category='Identifiers and Messaging' },
  @{ term='VPA'; definition='virtual payment address used in UPI transactions'; category='Identifiers and Messaging' },
  @{ term='UTR'; definition='unique transaction reference for tracking payment'; category='Identifiers and Messaging' },
  @{ term='RRN'; definition='retrieval reference number for card/payment tracking'; category='Identifiers and Messaging' },
  @{ term='ISO 8583'; definition='standard messaging format for card-based financial transactions'; category='Identifiers and Messaging' },
  @{ term='ISO 20022'; definition='XML-based universal messaging standard for payments'; category='Identifiers and Messaging' },
  @{ term='SWIFT MT'; definition='traditional SWIFT financial messaging format'; category='Identifiers and Messaging' },
  @{ term='SWIFT MX'; definition='ISO 20022 based SWIFT message format'; category='Identifiers and Messaging' },
  @{ term='Webhook Notification'; definition='event callback informing transaction status updates'; category='Identifiers and Messaging' },

  @{ term='MFA'; definition='multi-factor authentication requirement for secure payment access'; category='Security and Risk Controls' },
  @{ term='OTP'; definition='one-time password used for transaction authentication'; category='Security and Risk Controls' },
  @{ term='Tokenization'; definition='replacement of sensitive payment data with surrogate token'; category='Security and Risk Controls' },
  @{ term='PCI DSS'; definition='security standard for handling cardholder data'; category='Security and Risk Controls' },
  @{ term='Fraud Monitoring'; definition='continuous analysis to detect suspicious transaction behavior'; category='Security and Risk Controls' },
  @{ term='Velocity Rule'; definition='control limiting transaction count or amount in time window'; category='Security and Risk Controls' },
  @{ term='AML Screening'; definition='checks to identify suspicious money laundering patterns'; category='Security and Risk Controls' },
  @{ term='Sanctions Screening'; definition='validation against prohibited entities lists before processing'; category='Security and Risk Controls' },
  @{ term='Risk Scoring'; definition='assigning risk value to transaction based on indicators'; category='Security and Risk Controls' },
  @{ term='Dispute Management'; definition='workflow for handling transaction complaints and claims'; category='Security and Risk Controls' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which payment concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which payment systems area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct payment term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT transaction requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/payment_systems_transaction_flow.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


