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
  @{ term='ATM'; definition='self-service terminal enabling cash and non-cash banking transactions'; category='ATM Fundamentals' },
  @{ term='Card Issuer'; definition='bank that issues debit or credit card to customer'; category='ATM Fundamentals' },
  @{ term='Acquirer'; definition='institution that owns or manages ATM/merchant terminal'; category='ATM Fundamentals' },
  @{ term='Switch'; definition='network component routing ATM/card transaction messages'; category='ATM Fundamentals' },
  @{ term='Card BIN'; definition='first digits identifying issuing institution and card type'; category='ATM Fundamentals' },
  @{ term='Track Data'; definition='magnetic stripe data used for card transaction processing'; category='ATM Fundamentals' },
  @{ term='PIN'; definition='personal identification number used for cardholder verification'; category='ATM Fundamentals' },
  @{ term='PIN Block'; definition='encrypted format carrying PIN for secure transmission'; category='ATM Fundamentals' },
  @{ term='Authorization'; definition='issuer approval step for ATM/card transaction'; category='ATM Fundamentals' },
  @{ term='Reversal'; definition='message undoing previous failed or incomplete transaction'; category='ATM Fundamentals' },

  @{ term='Magnetic Stripe Card'; definition='card storing data in magnetic stripe tracks'; category='Card Technologies' },
  @{ term='EMV Chip Card'; definition='card with integrated chip for cryptographic transaction security'; category='Card Technologies' },
  @{ term='Contactless Card'; definition='card enabling tap transactions via NFC interface'; category='Card Technologies' },
  @{ term='CVV'; definition='card verification value printed for card-not-present checks'; category='Card Technologies' },
  @{ term='Expiry Date'; definition='date after which card is no longer valid'; category='Card Technologies' },
  @{ term='Card Tokenization'; definition='replacement of PAN with surrogate token for safety'; category='Card Technologies' },
  @{ term='PAN'; definition='primary account number uniquely identifying card account'; category='Card Technologies' },
  @{ term='Offline PIN'; definition='PIN verification performed by card/chip without host call'; category='Card Technologies' },
  @{ term='Online PIN'; definition='PIN verification performed by issuer host system'; category='Card Technologies' },
  @{ term='Dynamic CVV'; definition='time-varying CVV generated to reduce card fraud'; category='Card Technologies' },

  @{ term='Cash Withdrawal'; definition='ATM transaction where customer receives cash amount'; category='ATM Transactions' },
  @{ term='Balance Enquiry'; definition='ATM transaction retrieving account available balance'; category='ATM Transactions' },
  @{ term='Mini Statement'; definition='ATM transaction printing recent account entries'; category='ATM Transactions' },
  @{ term='PIN Change'; definition='ATM feature allowing customer to reset card PIN'; category='ATM Transactions' },
  @{ term='Cash Deposit'; definition='ATM transaction crediting account with deposited cash'; category='ATM Transactions' },
  @{ term='Fund Transfer'; definition='ATM transaction transferring amount between accounts'; category='ATM Transactions' },
  @{ term='Decline'; definition='transaction response indicating authorization failure'; category='ATM Transactions' },
  @{ term='Timeout'; definition='transaction failure due to delayed or missing response'; category='ATM Transactions' },
  @{ term='Partial Dispense'; definition='ATM cash payout issue where full amount not dispensed'; category='ATM Transactions' },
  @{ term='Dispute'; definition='customer complaint for mismatched or failed ATM/card transaction'; category='ATM Transactions' },

  @{ term='Skimming'; definition='fraud technique stealing card stripe data using hidden device'; category='Security and Fraud' },
  @{ term='Card Trapping'; definition='fraud method where card is retained by manipulated ATM slot'; category='Security and Fraud' },
  @{ term='Cash Trapping'; definition='fraud method preventing dispensed cash from reaching customer'; category='Security and Fraud' },
  @{ term='Shoulder Surfing'; definition='observing cardholder PIN entry to steal credentials'; category='Security and Fraud' },
  @{ term='ATM Jackpotting'; definition='malware-based unauthorized forced cash dispensing attack'; category='Security and Fraud' },
  @{ term='Anti-Skimming Device'; definition='ATM hardware protection against card skimming attempts'; category='Security and Fraud' },
  @{ term='PIN Shield'; definition='physical cover helping secure PIN entry privacy'; category='Security and Fraud' },
  @{ term='Velocity Check'; definition='fraud control detecting unusual transaction frequency/pattern'; category='Security and Fraud' },
  @{ term='Geolocation Check'; definition='fraud control comparing transaction location against expected profile'; category='Security and Fraud' },
  @{ term='Card Hotlisting'; definition='blocking compromised or lost cards from authorization'; category='Security and Fraud' },

  @{ term='PCI DSS'; definition='security standard for processing and storing cardholder data'; category='Operations and Compliance' },
  @{ term='Key Management'; definition='secure lifecycle management of cryptographic keys'; category='Operations and Compliance' },
  @{ term='HSM'; definition='hardware module for protected cryptographic key operations'; category='Operations and Compliance' },
  @{ term='Remote Key Loading'; definition='secure remote distribution of encryption keys to terminals'; category='Operations and Compliance' },
  @{ term='ATM Monitoring'; definition='continuous health and alert tracking of ATM terminals'; category='Operations and Compliance' },
  @{ term='First Line Maintenance'; definition='basic onsite corrective actions for ATM issues'; category='Operations and Compliance' },
  @{ term='Second Line Maintenance'; definition='advanced technical repair and hardware replacement support'; category='Operations and Compliance' },
  @{ term='Cash Replenishment'; definition='process of refilling ATM with cash cassettes'; category='Operations and Compliance' },
  @{ term='Reconciliation'; definition='matching ATM journal, switch, and core banking records'; category='Operations and Compliance' },
  @{ term='Downtime Management'; definition='tracking and reducing ATM service unavailability duration'; category='Operations and Compliance' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which ATM/Card concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which ATM/Card technology area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct ATM/Card term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT ATM operations requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/atm_card_technology.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


