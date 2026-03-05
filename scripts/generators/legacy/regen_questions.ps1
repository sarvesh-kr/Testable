Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

$topicsMeta = (Get-Content "data/topics.json" -Raw | ConvertFrom-Json).topics

$factMap = @{
  'computer_networks_cyber_security' = @(
    @{ p='device that forwards packets between networks'; a='Router' },
    @{ p='protocol used for secure remote login'; a='SSH' },
    @{ p='port number used by HTTPS'; a='443' },
    @{ p='OSI layer responsible for logical addressing'; a='Network Layer' },
    @{ p='attack that floods a server with traffic'; a='DDoS' }
  )
  'operating_system' = @(
    @{ p='scheduling algorithm with fixed time slice'; a='Round Robin' },
    @{ p='memory area used for function call frames'; a='Stack' },
    @{ p='state where processes wait indefinitely for resources'; a='Deadlock' },
    @{ p='system call used to create a new process in Unix'; a='fork()' },
    @{ p='technique that gives illusion of larger memory using disk'; a='Virtual Memory' }
  )
  'database_management_system' = @(
    @{ p='normal form that removes partial dependency'; a='Second Normal Form' },
    @{ p='SQL command used to remove all rows but keep table'; a='TRUNCATE' },
    @{ p='constraint that uniquely identifies each row'; a='Primary Key' },
    @{ p='property ensuring committed data survives failures'; a='Durability' },
    @{ p='join that returns matching rows from both tables only'; a='INNER JOIN' }
  )
  'computer_architecture' = @(
    @{ p='memory closest to CPU for frequently used data'; a='Cache Memory' },
    @{ p='register that holds address of next instruction'; a='Program Counter' },
    @{ p='binary arithmetic unit inside CPU'; a='ALU' },
    @{ p='execution design that overlaps instruction stages'; a='Pipelining' },
    @{ p='interrupt that can be ignored by CPU'; a='Maskable Interrupt' }
  )
  'software_engineering' = @(
    @{ p='model where each phase completes before next begins'; a='Waterfall Model' },
    @{ p='document that captures functional and non-functional needs'; a='SRS' },
    @{ p='testing performed on integrated modules'; a='Integration Testing' },
    @{ p='metric that measures delivered functionality size'; a='Function Point' },
    @{ p='agile ceremony used to estimate work'; a='Sprint Planning' }
  )
  'cloud_devops' = @(
    @{ p='cloud model that provides virtual machines and networks'; a='IaaS' },
    @{ p='practice of automatically building and testing code'; a='CI' },
    @{ p='tool commonly used for container orchestration'; a='Kubernetes' },
    @{ p='deployment strategy shifting traffic gradually'; a='Canary Deployment' },
    @{ p='infrastructure management approach using versioned files'; a='Infrastructure as Code' }
  )
  'programming_software_development' = @(
    @{ p='principle of bundling data and methods together'; a='Encapsulation' },
    @{ p='runtime handling of overloaded/overridden methods'; a='Polymorphism' },
    @{ p='data type that stores true/false'; a='Boolean' },
    @{ p='keyword used to handle exceptions in Java/C#'; a='catch' },
    @{ p='version control operation that combines branches'; a='merge' }
  )
  'data_structure_algorithm' = @(
    @{ p='data structure that follows FIFO order'; a='Queue' },
    @{ p='average time complexity of binary search'; a='O(log n)' },
    @{ p='traversal where root is visited between left and right'; a='Inorder Traversal' },
    @{ p='graph algorithm used for shortest path with non-negative weights'; a='Dijkstra Algorithm' },
    @{ p='sorting algorithm with divide-and-conquer and stable behavior'; a='Merge Sort' }
  )
  'web_app_development_fundamentals' = @(
    @{ p='HTTP method typically used to create a resource'; a='POST' },
    @{ p='status code meaning resource not found'; a='404' },
    @{ p='client-side storage sent with each HTTP request'; a='Cookie' },
    @{ p='markup language used for web page structure'; a='HTML' },
    @{ p='policy that restricts cross-origin browser requests'; a='Same-Origin Policy' }
  )
  'cryptography_digital_security' = @(
    @{ p='encryption approach using same key for encrypt/decrypt'; a='Symmetric Encryption' },
    @{ p='algorithm commonly used for key exchange'; a='Diffie-Hellman' },
    @{ p='hash algorithm family used for integrity checks'; a='SHA-2' },
    @{ p='digital certificate standard used on the web'; a='X.509' },
    @{ p='property proving sender cannot deny message creation'; a='Non-Repudiation' }
  )
  'secure_coding_web_security' = @(
    @{ p='vulnerability caused by untrusted SQL concatenation'; a='SQL Injection' },
    @{ p='attack where malicious scripts run in user browser'; a='Cross-Site Scripting' },
    @{ p='best protection against CSRF in forms'; a='CSRF Token Validation' },
    @{ p='header that prevents MIME type sniffing'; a='X-Content-Type-Options' },
    @{ p='practice of validating input on server side'; a='Server-Side Input Validation' }
  )
  'core_banking_digital_banking' = @(
    @{ p='system that processes branch transactions centrally'; a='Core Banking System' },
    @{ p='process of confirming customer identity'; a='KYC' },
    @{ p='banking channel accessed via smartphone app'; a='Mobile Banking' },
    @{ p='account transfer mode within same bank in real time'; a='IMPS' },
    @{ p='customer authentication factor based on biometrics'; a='Inherence Factor' }
  )
  'payment_systems_transaction_flow' = @(
    @{ p='NPCI platform used for instant account-to-account transfer'; a='UPI' },
    @{ p='payment stage where issuer verifies cardholder'; a='Authorization' },
    @{ p='process of exchanging transaction files between banks'; a='Clearing' },
    @{ p='final transfer of funds after clearing'; a='Settlement' },
    @{ p='identifier used to route electronic fund transfer in India'; a='IFSC' }
  )
  'atm_card_technology' = @(
    @{ p='card security code printed on card back'; a='CVV' },
    @{ p='technology that stores card data on embedded chip'; a='EMV Chip' },
    @{ p='device attack where data is copied from magnetic stripe'; a='Skimming' },
    @{ p='ATM transaction that does not dispense cash'; a='Balance Enquiry' },
    @{ p='standard for secure PIN block format in ATM networks'; a='ISO 9564' }
  )
  'it_operations_incident_management' = @(
    @{ p='ITIL process to restore service quickly after failure'; a='Incident Management' },
    @{ p='record used to track operational issue lifecycle'; a='Ticket' },
    @{ p='analysis performed after major outage to find root cause'; a='RCA' },
    @{ p='metric indicating average time to recover service'; a='MTTR' },
    @{ p='planned temporary workaround before permanent fix'; a='Workaround' }
  )
  'monitoring_logging' = @(
    @{ p='metric category measuring request delay'; a='Latency' },
    @{ p='log level used for severe failure events'; a='ERROR' },
    @{ p='dashboard alert signal for threshold breach'; a='Alert Trigger' },
    @{ p='technique of attaching request id across services'; a='Distributed Tracing' },
    @{ p='ratio of successful requests to total requests'; a='Availability' }
  )
  'banking_cyber_security' = @(
    @{ p='fraud where user is tricked through fake communication'; a='Phishing' },
    @{ p='control requiring two independent authentication factors'; a='MFA' },
    @{ p='security operation that simulates real attacks'; a='Penetration Testing' },
    @{ p='team that continuously monitors cyber threats'; a='SOC' },
    @{ p='process of restricting access by least privilege'; a='Access Control' }
  )
  'backup_disaster_recovery' = @(
    @{ p='maximum acceptable data loss window'; a='RPO' },
    @{ p='maximum acceptable downtime for service restore'; a='RTO' },
    @{ p='backup type capturing only changes since last backup'; a='Incremental Backup' },
    @{ p='offsite standby setup for critical systems'; a='Disaster Recovery Site' },
    @{ p='test ensuring backups can be restored successfully'; a='Restore Drill' }
  )
  'email_systems' = @(
    @{ p='protocol used by clients to send outgoing mail'; a='SMTP' },
    @{ p='email authentication record preventing spoofing'; a='SPF' },
    @{ p='protocol commonly used to sync mailboxes across devices'; a='IMAP' },
    @{ p='mechanism that adds cryptographic signature to email domain'; a='DKIM' },
    @{ p='policy framework built on SPF and DKIM results'; a='DMARC' }
  )
}

function Shuffle($arr) {
  return @($arr | Sort-Object { Get-Random })
}

foreach ($topic in $topicsMeta) {
  $facts = $factMap[$topic.id]
  if (-not $facts) {
    throw "Missing facts for topic id: $($topic.id)"
  }

  $questions = @()
  $qid = 1

  foreach ($fact in $facts) {
    $distractors = @($facts | Where-Object { $_['a'] -ne $fact['a'] } | ForEach-Object { $_['a'] })
    $opts1 = @($fact['a'])
    $opts1 += @($distractors | Get-Random -Count 3)
    $opts1 = Shuffle $opts1

    $ans1 = [array]::IndexOf($opts1, $fact['a'])
    $questions += [ordered]@{
      id = $qid
      question = "Which of the following is the best answer for: $($fact['p'])?"
      options = @($opts1[0], $opts1[1], $opts1[2], $opts1[3])
      answer = $ans1
      explanation = "$($fact['a']) is the correct match for '$($fact['p'])'."
    }
    $qid++

    $pairsWrong = @()
    foreach ($other in @($facts | Where-Object { $_['a'] -ne $fact['a'] } | Get-Random -Count 3)) {
      $pairsWrong += "$($other['p']) -> $($fact['a'])"
    }
    $correctPair = "$($fact['p']) -> $($fact['a'])"
    $opts2 = @($correctPair)
    $opts2 += @($pairsWrong)
    $opts2 = Shuffle $opts2

    $ans2 = [array]::IndexOf($opts2, $correctPair)
    $questions += [ordered]@{
      id = $qid
      question = "Identify the correct concept mapping for $($topic.name)."
      options = @($opts2[0], $opts2[1], $opts2[2], $opts2[3])
      answer = $ans2
      explanation = "Only '$correctPair' is correctly mapped."
    }
    $qid++

    $descOptions = @(
      "It primarily refers to $($fact['p']).",
      "It always replaces multi-factor authentication in banks.",
      "It is a hardware-only feature with no software role.",
      "It is unrelated to security or operations in IT systems."
    )
    $descOptions = Shuffle $descOptions
    $target = "It primarily refers to $($fact['p'])."

    $ans3 = [array]::IndexOf($descOptions, $target)
    $questions += [ordered]@{
      id = $qid
      question = "Which statement is most accurate about '$($fact['a'])'?"
      options = @($descOptions[0], $descOptions[1], $descOptions[2], $descOptions[3])
      answer = $ans3
      explanation = "In exam context, '$($fact['a'])' is associated with $($fact['p'])."
    }
    $qid++
  }

  [ordered]@{ questions = @($questions) } |
    ConvertTo-Json -Depth 8 |
    Set-Content -Path ("data/topics/" + $topic.file) -Encoding utf8
}

$allTopicQuestions = @()
foreach ($topic in $topicsMeta) {
  $allTopicQuestions += @((Get-Content ("data/topics/" + $topic.file) -Raw | ConvertFrom-Json).questions)
}

for ($m = 1; $m -le 3; $m++) {
  $picked = @()
  for ($i = 1; $i -le 100; $i++) {
    $q = $allTopicQuestions[($i * $m + $i) % $allTopicQuestions.Count]
    $picked += [ordered]@{
      id = $i
      question = $q.question
      options = @($q.options[0], $q.options[1], $q.options[2], $q.options[3])
      answer = $q.answer
      explanation = $q.explanation
    }
  }

  [ordered]@{ questions = @($picked) } |
    ConvertTo-Json -Depth 8 |
    Set-Content -Path ("data/mocks/mock" + $m + ".json") -Encoding utf8
}

Write-Output "Question banks regenerated successfully."

