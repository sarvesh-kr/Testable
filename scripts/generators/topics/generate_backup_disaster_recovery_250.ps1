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
  @{ term='Backup'; definition='process of creating copies of data for recovery needs'; category='Backup Fundamentals' },
  @{ term='Restore'; definition='process of recovering data from backup copy'; category='Backup Fundamentals' },
  @{ term='Disaster Recovery'; definition='capability to restore services after major disruption'; category='Backup Fundamentals' },
  @{ term='Business Continuity'; definition='ability to maintain critical operations during disruption'; category='Backup Fundamentals' },
  @{ term='Backup Policy'; definition='documented rules for frequency, retention, and responsibility'; category='Backup Fundamentals' },
  @{ term='Retention Period'; definition='duration backups are preserved before deletion'; category='Backup Fundamentals' },
  @{ term='Backup Window'; definition='scheduled time period allocated for backup operations'; category='Backup Fundamentals' },
  @{ term='Recovery Plan'; definition='documented procedure to restore systems and data'; category='Backup Fundamentals' },
  @{ term='Critical System'; definition='system whose unavailability causes significant business impact'; category='Backup Fundamentals' },
  @{ term='Data Classification'; definition='categorization of data based on sensitivity and criticality'; category='Backup Fundamentals' },

  @{ term='Full Backup'; definition='backup containing complete copy of selected data'; category='Backup Types and Strategies' },
  @{ term='Incremental Backup'; definition='backup containing changes since last backup of any type'; category='Backup Types and Strategies' },
  @{ term='Differential Backup'; definition='backup containing changes since last full backup'; category='Backup Types and Strategies' },
  @{ term='Synthetic Full Backup'; definition='new full backup assembled from previous full and incrementals'; category='Backup Types and Strategies' },
  @{ term='Snapshot'; definition='point-in-time image of data or volume state'; category='Backup Types and Strategies' },
  @{ term='Mirror Backup'; definition='real-time duplicate copy maintaining near-identical dataset'; category='Backup Types and Strategies' },
  @{ term='Hot Backup'; definition='backup taken while system remains online and active'; category='Backup Types and Strategies' },
  @{ term='Cold Backup'; definition='backup taken when system is offline'; category='Backup Types and Strategies' },
  @{ term='Offsite Backup'; definition='backup copy stored at geographically separate location'; category='Backup Types and Strategies' },
  @{ term='Immutable Backup'; definition='backup that cannot be altered or deleted during lock period'; category='Backup Types and Strategies' },

  @{ term='RPO'; definition='maximum acceptable data loss measured in time'; category='Recovery Objectives' },
  @{ term='RTO'; definition='maximum acceptable time to restore service'; category='Recovery Objectives' },
  @{ term='Recovery Time'; definition='actual elapsed time to restore affected service'; category='Recovery Objectives' },
  @{ term='Recovery Point'; definition='point in time to which data is restored'; category='Recovery Objectives' },
  @{ term='Failover'; definition='switching operations to alternate site or system'; category='Recovery Objectives' },
  @{ term='Failback'; definition='returning operations to primary site after recovery'; category='Recovery Objectives' },
  @{ term='Warm Site'; definition='partially equipped DR site needing additional setup'; category='Recovery Objectives' },
  @{ term='Hot Site'; definition='fully operational DR site with minimal activation delay'; category='Recovery Objectives' },
  @{ term='Cold Site'; definition='basic DR location requiring major setup before use'; category='Recovery Objectives' },
  @{ term='Recovery Priority'; definition='ordered sequence of systems restored based on business impact'; category='Recovery Objectives' },

  @{ term='Backup Verification'; definition='process confirming backups are complete and usable'; category='Validation and Testing' },
  @{ term='Restore Testing'; definition='periodic test proving recoverability of backup data'; category='Validation and Testing' },
  @{ term='DR Drill'; definition='simulated exercise validating disaster recovery procedures'; category='Validation and Testing' },
  @{ term='Checksum Validation'; definition='integrity check comparing hash values of data'; category='Validation and Testing' },
  @{ term='Recovery Runbook'; definition='step-by-step operational guide for recovery execution'; category='Validation and Testing' },
  @{ term='Tabletop Exercise'; definition='discussion-based scenario walkthrough for preparedness'; category='Validation and Testing' },
  @{ term='Gap Analysis'; definition='assessment identifying differences between current and target readiness'; category='Validation and Testing' },
  @{ term='Post Drill Review'; definition='analysis of drill outcomes and improvement actions'; category='Validation and Testing' },
  @{ term='Audit Evidence'; definition='documented proof of backup and recovery control execution'; category='Validation and Testing' },
  @{ term='Control Maturity'; definition='degree to which backup controls are formalized and effective'; category='Validation and Testing' },

  @{ term='Backup Encryption'; definition='cryptographic protection of backup data at rest and transit'; category='Security and Compliance' },
  @{ term='Key Management'; definition='secure lifecycle handling of encryption keys'; category='Security and Compliance' },
  @{ term='Access Control'; definition='restriction of backup system access to authorized users'; category='Security and Compliance' },
  @{ term='Segregation of Duties'; definition='separation of backup administration and approval roles'; category='Security and Compliance' },
  @{ term='Ransomware Resilience'; definition='capability to recover safely from ransomware incidents'; category='Security and Compliance' },
  @{ term='Air-Gapped Backup'; definition='backup isolated from production network to resist compromise'; category='Security and Compliance' },
  @{ term='Data Sovereignty'; definition='requirement that data remains within specific legal jurisdictions'; category='Security and Compliance' },
  @{ term='Regulatory Compliance'; definition='adherence to applicable banking and security regulations'; category='Security and Compliance' },
  @{ term='Log Retention'; definition='preservation of backup operation logs for audit and investigation'; category='Security and Compliance' },
  @{ term='Incident Escalation'; definition='timely notification path for backup/recovery failures'; category='Security and Compliance' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which backup/DR concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which backup/disaster recovery area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct backup/DR term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT resilience requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/backup_disaster_recovery.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


