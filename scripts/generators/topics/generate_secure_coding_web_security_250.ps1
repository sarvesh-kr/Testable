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
  @{ term='Secure Coding'; definition='development practice focused on preventing security vulnerabilities in code'; category='Secure Development Fundamentals' },
  @{ term='Input Validation'; definition='checking and sanitizing user input before processing'; category='Secure Development Fundamentals' },
  @{ term='Output Encoding'; definition='escaping output based on rendering context to prevent injection'; category='Secure Development Fundamentals' },
  @{ term='Least Privilege'; definition='granting minimum permissions required for a task'; category='Secure Development Fundamentals' },
  @{ term='Defense in Depth'; definition='using multiple layered controls for stronger protection'; category='Secure Development Fundamentals' },
  @{ term='Fail Secure'; definition='system behavior that defaults to secure state on failure'; category='Secure Development Fundamentals' },
  @{ term='Threat Modeling'; definition='structured identification of assets, threats, and mitigations'; category='Secure Development Fundamentals' },
  @{ term='Static Analysis'; definition='automated code scanning without program execution'; category='Secure Development Fundamentals' },
  @{ term='Dynamic Analysis'; definition='testing running application for runtime security issues'; category='Secure Development Fundamentals' },
  @{ term='Software Composition Analysis'; definition='identifying vulnerabilities in third-party dependencies'; category='Secure Development Fundamentals' },

  @{ term='SQL Injection'; definition='injection flaw where crafted input manipulates SQL queries'; category='Common Web Vulnerabilities' },
  @{ term='Cross-Site Scripting'; definition='vulnerability allowing script execution in victim browser'; category='Common Web Vulnerabilities' },
  @{ term='CSRF'; definition='attack forcing authenticated user to send unwanted request'; category='Common Web Vulnerabilities' },
  @{ term='Command Injection'; definition='vulnerability allowing execution of unintended system commands'; category='Common Web Vulnerabilities' },
  @{ term='Path Traversal'; definition='vulnerability enabling unauthorized file access via path manipulation'; category='Common Web Vulnerabilities' },
  @{ term='Insecure Deserialization'; definition='unsafe object deserialization enabling code execution or tampering'; category='Common Web Vulnerabilities' },
  @{ term='Broken Access Control'; definition='flaw allowing unauthorized action due to weak authorization checks'; category='Common Web Vulnerabilities' },
  @{ term='Authentication Bypass'; definition='flaw allowing login without valid credentials'; category='Common Web Vulnerabilities' },
  @{ term='Session Fixation'; definition='attack forcing victim to use attacker-controlled session identifier'; category='Common Web Vulnerabilities' },
  @{ term='Clickjacking'; definition='trick using hidden UI layers to hijack user clicks'; category='Common Web Vulnerabilities' },

  @{ term='Prepared Statement'; definition='parameterized database query separating code from user input'; category='Mitigation Techniques' },
  @{ term='Parameterized Query'; definition='query technique binding user values as parameters'; category='Mitigation Techniques' },
  @{ term='Allowlist Validation'; definition='accepting only known-good input patterns or values'; category='Mitigation Techniques' },
  @{ term='Content Security Policy'; definition='header controlling allowed content sources in browser'; category='Mitigation Techniques' },
  @{ term='HTTPOnly Cookie'; definition='cookie flag preventing JavaScript access to cookie data'; category='Mitigation Techniques' },
  @{ term='Secure Cookie'; definition='cookie flag allowing transmission only over HTTPS'; category='Mitigation Techniques' },
  @{ term='SameSite Cookie'; definition='cookie attribute reducing cross-site request risk'; category='Mitigation Techniques' },
  @{ term='CSRF Token'; definition='unpredictable token validated to defend CSRF attacks'; category='Mitigation Techniques' },
  @{ term='Rate Limiting'; definition='control restricting request frequency to prevent abuse'; category='Mitigation Techniques' },
  @{ term='Password Hashing'; definition='one-way transformation of passwords for secure storage'; category='Mitigation Techniques' },

  @{ term='Authentication'; definition='process of verifying identity of user or system'; category='Identity and Access Security' },
  @{ term='Authorization'; definition='process of enforcing permissions for authenticated identity'; category='Identity and Access Security' },
  @{ term='MFA'; definition='authentication requiring two or more independent factors'; category='Identity and Access Security' },
  @{ term='OAuth 2.0'; definition='authorization framework for delegated access to resources'; category='Identity and Access Security' },
  @{ term='OpenID Connect'; definition='identity layer built on top of OAuth 2.0'; category='Identity and Access Security' },
  @{ term='JWT'; definition='compact signed token format for claims and identity data'; category='Identity and Access Security' },
  @{ term='Role-Based Access Control'; definition='access model assigning permissions based on roles'; category='Identity and Access Security' },
  @{ term='Privilege Escalation'; definition='gaining higher permissions than originally granted'; category='Identity and Access Security' },
  @{ term='Account Lockout'; definition='temporary account disablement after repeated failed logins'; category='Identity and Access Security' },
  @{ term='Secrets Management'; definition='secure storage and rotation of credentials and keys'; category='Identity and Access Security' },

  @{ term='TLS'; definition='protocol providing encryption and integrity for data in transit'; category='Transport and API Security' },
  @{ term='HSTS'; definition='header forcing browser to use HTTPS for domain'; category='Transport and API Security' },
  @{ term='API Gateway'; definition='entry layer enforcing policy, auth, and routing for APIs'; category='Transport and API Security' },
  @{ term='API Key'; definition='identifier used to authenticate client application requests'; category='Transport and API Security' },
  @{ term='Idempotency Key'; definition='unique request token preventing duplicate processing'; category='Transport and API Security' },
  @{ term='WAF'; definition='firewall filtering malicious HTTP traffic for web applications'; category='Transport and API Security' },
  @{ term='Security Logging'; definition='recording security-relevant events for monitoring and audit'; category='Transport and API Security' },
  @{ term='SIEM Correlation'; definition='analysis linking events across sources to detect threats'; category='Transport and API Security' },
  @{ term='Incident Response'; definition='process of detecting, containing, and recovering from security incidents'; category='Transport and API Security' },
  @{ term='Vulnerability Management'; definition='continuous process of identifying and remediating weaknesses'; category='Transport and API Security' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which secure coding/web security concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which secure coding/web security area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct secure coding term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT application security requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/secure_coding_web_security.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


