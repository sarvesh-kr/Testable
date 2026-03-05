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
  @{ term='Email System'; definition='infrastructure enabling composition, transfer, and storage of email messages'; category='Email Fundamentals' },
  @{ term='SMTP'; definition='protocol used to send email between clients and servers'; category='Email Fundamentals' },
  @{ term='POP3'; definition='protocol used to download email from server to client'; category='Email Fundamentals' },
  @{ term='IMAP'; definition='protocol used to synchronize mailbox content across devices'; category='Email Fundamentals' },
  @{ term='MUA'; definition='mail user agent used by end user to read and compose email'; category='Email Fundamentals' },
  @{ term='MTA'; definition='mail transfer agent responsible for relaying email between servers'; category='Email Fundamentals' },
  @{ term='MDA'; definition='mail delivery agent placing incoming message into mailbox'; category='Email Fundamentals' },
  @{ term='Mailbox'; definition='storage location where user emails are retained'; category='Email Fundamentals' },
  @{ term='Attachment'; definition='file sent along with email message body'; category='Email Fundamentals' },
  @{ term='MIME'; definition='standard enabling non-text content and attachments in email'; category='Email Fundamentals' },

  @{ term='DNS MX Record'; definition='DNS record specifying mail server responsible for a domain'; category='Mail Routing and Delivery' },
  @{ term='Mail Relay'; definition='server forwarding email from one SMTP server to another'; category='Mail Routing and Delivery' },
  @{ term='Open Relay'; definition='misconfigured relay allowing unauthenticated message forwarding'; category='Mail Routing and Delivery' },
  @{ term='Queue Management'; definition='handling deferred emails awaiting delivery retry'; category='Mail Routing and Delivery' },
  @{ term='Bounce'; definition='non-delivery report generated when message fails permanently'; category='Mail Routing and Delivery' },
  @{ term='Soft Bounce'; definition='temporary delivery failure often retried later'; category='Mail Routing and Delivery' },
  @{ term='Hard Bounce'; definition='permanent delivery failure due to invalid recipient/domain'; category='Mail Routing and Delivery' },
  @{ term='TLS for SMTP'; definition='encryption of SMTP transport channel between mail servers'; category='Mail Routing and Delivery' },
  @{ term='SMTP Authentication'; definition='credential verification before allowing message submission'; category='Mail Routing and Delivery' },
  @{ term='Submission Port 587'; definition='standard SMTP submission port for authenticated clients'; category='Mail Routing and Delivery' },

  @{ term='SPF'; definition='email authentication method validating authorized sending hosts'; category='Email Security and Anti-Abuse' },
  @{ term='DKIM'; definition='domain-level cryptographic signing for email integrity validation'; category='Email Security and Anti-Abuse' },
  @{ term='DMARC'; definition='policy framework using SPF and DKIM alignment results'; category='Email Security and Anti-Abuse' },
  @{ term='Phishing Email'; definition='fraudulent email attempting to steal credentials or data'; category='Email Security and Anti-Abuse' },
  @{ term='Business Email Compromise'; definition='targeted fraud impersonating trusted business identities'; category='Email Security and Anti-Abuse' },
  @{ term='Spam'; definition='unsolicited bulk email communication'; category='Email Security and Anti-Abuse' },
  @{ term='Malicious Attachment'; definition='infected file delivered through email'; category='Email Security and Anti-Abuse' },
  @{ term='URL Rewriting'; definition='security mechanism replacing links for click-time inspection'; category='Email Security and Anti-Abuse' },
  @{ term='Email Sandboxing'; definition='isolated execution of suspicious attachments and links'; category='Email Security and Anti-Abuse' },
  @{ term='Quarantine'; definition='holding area for messages flagged as suspicious'; category='Email Security and Anti-Abuse' },

  @{ term='Email Gateway'; definition='security/control point filtering inbound and outbound mail'; category='Operations and Administration' },
  @{ term='Distribution List'; definition='group address delivering message to multiple recipients'; category='Operations and Administration' },
  @{ term='Alias'; definition='alternate email address mapped to one mailbox'; category='Operations and Administration' },
  @{ term='Auto-Responder'; definition='automatic reply triggered by predefined conditions'; category='Operations and Administration' },
  @{ term='Mailbox Quota'; definition='maximum allowed mailbox storage size for user'; category='Operations and Administration' },
  @{ term='Archiving'; definition='long-term preservation of email for retention/compliance'; category='Operations and Administration' },
  @{ term='Retention Policy'; definition='rules defining how long email data is kept'; category='Operations and Administration' },
  @{ term='eDiscovery'; definition='search and retrieval process for legal/compliance requests'; category='Operations and Administration' },
  @{ term='Journaling'; definition='capture of all inbound/outbound emails for audit'; category='Operations and Administration' },
  @{ term='Backup Mailbox Restore'; definition='recovery of mailbox content from backup copy'; category='Operations and Administration' },

  @{ term='Message Trace'; definition='tracking route and status of specific email'; category='Troubleshooting and Reliability' },
  @{ term='Delivery Delay'; definition='slow message transit due to queue/load/network factors'; category='Troubleshooting and Reliability' },
  @{ term='NDR'; definition='non-delivery report returned for failed recipient delivery'; category='Troubleshooting and Reliability' },
  @{ term='Blacklist'; definition='list of blocked senders/IPs due to abuse indicators'; category='Troubleshooting and Reliability' },
  @{ term='Whitelist'; definition='approved sender list bypassing strict filtering checks'; category='Troubleshooting and Reliability' },
  @{ term='Reputation Score'; definition='trust rating influencing sender acceptance decisions'; category='Troubleshooting and Reliability' },
  @{ term='Mail Flow Rule'; definition='policy-based condition-action logic for message handling'; category='Troubleshooting and Reliability' },
  @{ term='High Availability'; definition='design ensuring mail service continuity with redundancy'; category='Troubleshooting and Reliability' },
  @{ term='Failover Mail Server'; definition='secondary server activated when primary server fails'; category='Troubleshooting and Reliability' },
  @{ term='Capacity Planning'; definition='forecasting resources for future email traffic/storage demand'; category='Troubleshooting and Reliability' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which email systems concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which email systems area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct email systems term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT email operations requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/email_systems.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


