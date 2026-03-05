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
  @{ term='Cyber Security'; definition='protection of systems, networks, and data from digital attacks'; category='Security Fundamentals' },
  @{ term='Confidentiality'; definition='ensuring data is accessible only to authorized entities'; category='Security Fundamentals' },
  @{ term='Integrity'; definition='ensuring data remains accurate and unaltered'; category='Security Fundamentals' },
  @{ term='Availability'; definition='ensuring systems and data are accessible when needed'; category='Security Fundamentals' },
  @{ term='Defense in Depth'; definition='multiple layered controls to reduce attack success'; category='Security Fundamentals' },
  @{ term='Zero Trust'; definition='security model requiring continuous verification for every access'; category='Security Fundamentals' },
  @{ term='Least Privilege'; definition='granting only minimum required access permissions'; category='Security Fundamentals' },
  @{ term='Segregation of Duties'; definition='splitting critical tasks among different individuals'; category='Security Fundamentals' },
  @{ term='Asset Inventory'; definition='catalog of systems, applications, and data requiring protection'; category='Security Fundamentals' },
  @{ term='Security Policy'; definition='formal document defining organizational security expectations'; category='Security Fundamentals' },

  @{ term='Phishing'; definition='social engineering attack using deceptive communication'; category='Threats and Fraud' },
  @{ term='Spear Phishing'; definition='targeted phishing tailored to specific individual or role'; category='Threats and Fraud' },
  @{ term='Vishing'; definition='voice call based social engineering fraud'; category='Threats and Fraud' },
  @{ term='Smishing'; definition='SMS based social engineering attack'; category='Threats and Fraud' },
  @{ term='Malware'; definition='malicious software designed to disrupt or steal'; category='Threats and Fraud' },
  @{ term='Ransomware'; definition='malware encrypting data and demanding ransom payment'; category='Threats and Fraud' },
  @{ term='Trojan'; definition='malware disguised as legitimate software'; category='Threats and Fraud' },
  @{ term='DDoS'; definition='distributed attack overwhelming service resources'; category='Threats and Fraud' },
  @{ term='Credential Stuffing'; definition='automated login attempts using leaked credentials'; category='Threats and Fraud' },
  @{ term='Account Takeover'; definition='unauthorized control of legitimate customer account'; category='Threats and Fraud' },

  @{ term='MFA'; definition='authentication requiring two or more independent factors'; category='Identity and Access Security' },
  @{ term='Password Policy'; definition='rules for complexity, rotation, and reuse prevention'; category='Identity and Access Security' },
  @{ term='Biometric Authentication'; definition='identity verification using biological characteristics'; category='Identity and Access Security' },
  @{ term='Device Fingerprinting'; definition='identifying device characteristics for risk assessment'; category='Identity and Access Security' },
  @{ term='Session Management'; definition='secure handling of user session lifecycle'; category='Identity and Access Security' },
  @{ term='Privileged Access Management'; definition='control and monitoring of elevated access accounts'; category='Identity and Access Security' },
  @{ term='Role-Based Access Control'; definition='permission model based on user roles'; category='Identity and Access Security' },
  @{ term='Access Recertification'; definition='periodic review and validation of user entitlements'; category='Identity and Access Security' },
  @{ term='Account Lockout'; definition='temporary disablement after repeated failed logins'; category='Identity and Access Security' },
  @{ term='Risk-Based Authentication'; definition='adaptive authentication based on contextual risk signals'; category='Identity and Access Security' },

  @{ term='SIEM'; definition='platform correlating logs and events for threat detection'; category='Detection and Response' },
  @{ term='SOC'; definition='team responsible for continuous security monitoring and response'; category='Detection and Response' },
  @{ term='EDR'; definition='endpoint detection and response for suspicious host behavior'; category='Detection and Response' },
  @{ term='Threat Intelligence'; definition='contextual information about adversaries and indicators'; category='Detection and Response' },
  @{ term='IOC'; definition='indicator suggesting potential compromise activity'; category='Detection and Response' },
  @{ term='Incident Response'; definition='process to detect, contain, eradicate, and recover'; category='Detection and Response' },
  @{ term='Containment'; definition='steps to limit spread and impact of incident'; category='Detection and Response' },
  @{ term='Forensics'; definition='collection and analysis of digital evidence'; category='Detection and Response' },
  @{ term='RCA'; definition='root cause analysis to identify underlying failure source'; category='Detection and Response' },
  @{ term='Post Incident Review'; definition='review documenting lessons and corrective actions'; category='Detection and Response' },

  @{ term='Data Encryption'; definition='protecting data confidentiality using cryptographic methods'; category='Banking Controls and Compliance' },
  @{ term='Tokenization'; definition='replacing sensitive data with non-sensitive substitute tokens'; category='Banking Controls and Compliance' },
  @{ term='Data Loss Prevention'; definition='controls preventing unauthorized sensitive data exfiltration'; category='Banking Controls and Compliance' },
  @{ term='PCI DSS'; definition='security standard for handling payment card data'; category='Banking Controls and Compliance' },
  @{ term='Regulatory Compliance'; definition='adherence to laws, circulars, and supervisory requirements'; category='Banking Controls and Compliance' },
  @{ term='Audit Trail'; definition='immutable record of user and system actions'; category='Banking Controls and Compliance' },
  @{ term='Vulnerability Assessment'; definition='systematic identification of security weaknesses'; category='Banking Controls and Compliance' },
  @{ term='Patch Management'; definition='timely deployment of updates reducing exploitability'; category='Banking Controls and Compliance' },
  @{ term='Business Continuity'; definition='ability to continue critical banking operations during disruption'; category='Banking Controls and Compliance' },
  @{ term='Disaster Recovery'; definition='capability to restore services and data after major outage'; category='Banking Controls and Compliance' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which banking cyber security concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which banking cyber security area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct cyber security term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT cyber security requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/banking_cyber_security.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


