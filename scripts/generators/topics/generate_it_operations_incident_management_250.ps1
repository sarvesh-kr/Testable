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
  @{ term='IT Operations'; definition='activities that ensure stable and efficient IT service delivery'; category='Operations Fundamentals' },
  @{ term='Incident'; definition='unplanned interruption or degradation of IT service'; category='Operations Fundamentals' },
  @{ term='Major Incident'; definition='high-impact incident requiring urgent coordinated response'; category='Operations Fundamentals' },
  @{ term='Service Request'; definition='formal user request for standard service action'; category='Operations Fundamentals' },
  @{ term='Event'; definition='detectable occurrence with significance for service management'; category='Operations Fundamentals' },
  @{ term='Alert'; definition='notification indicating threshold breach or abnormal condition'; category='Operations Fundamentals' },
  @{ term='Ticket'; definition='record used to track issue lifecycle and actions'; category='Operations Fundamentals' },
  @{ term='Escalation'; definition='routing issue to higher support level or management'; category='Operations Fundamentals' },
  @{ term='Runbook'; definition='documented procedural steps for routine operational tasks'; category='Operations Fundamentals' },
  @{ term='SOP'; definition='standard operating procedure for consistent execution of tasks'; category='Operations Fundamentals' },

  @{ term='Incident Management'; definition='process to restore normal service quickly after disruption'; category='ITIL Processes' },
  @{ term='Problem Management'; definition='process focused on identifying and removing root causes'; category='ITIL Processes' },
  @{ term='Change Management'; definition='process controlling lifecycle of production changes'; category='ITIL Processes' },
  @{ term='Release Management'; definition='process planning and controlling software/service releases'; category='ITIL Processes' },
  @{ term='Configuration Management'; definition='process maintaining accurate IT asset and relationship data'; category='ITIL Processes' },
  @{ term='Service Level Management'; definition='process defining and monitoring service targets'; category='ITIL Processes' },
  @{ term='Capacity Management'; definition='process ensuring infrastructure meets current and future demand'; category='ITIL Processes' },
  @{ term='Availability Management'; definition='process maximizing service uptime and resilience'; category='ITIL Processes' },
  @{ term='IT Service Continuity Management'; definition='process preparing services for disaster scenarios'; category='ITIL Processes' },
  @{ term='Knowledge Management'; definition='process capturing and reusing operational knowledge articles'; category='ITIL Processes' },

  @{ term='RCA'; definition='root cause analysis method to identify underlying issue reason'; category='Incident Analysis and Resolution' },
  @{ term='Known Error'; definition='documented problem with identified root cause and workaround'; category='Incident Analysis and Resolution' },
  @{ term='Workaround'; definition='temporary measure reducing impact before permanent fix'; category='Incident Analysis and Resolution' },
  @{ term='MTTR'; definition='mean time to restore service after incident'; category='Incident Analysis and Resolution' },
  @{ term='MTTD'; definition='mean time to detect incident occurrence'; category='Incident Analysis and Resolution' },
  @{ term='SLA Breach'; definition='failure to meet agreed service target commitments'; category='Incident Analysis and Resolution' },
  @{ term='Impact'; definition='extent of business effect caused by an incident'; category='Incident Analysis and Resolution' },
  @{ term='Urgency'; definition='speed at which incident resolution is required'; category='Incident Analysis and Resolution' },
  @{ term='Priority Matrix'; definition='model deriving incident priority from impact and urgency'; category='Incident Analysis and Resolution' },
  @{ term='Post Incident Review'; definition='structured review after closure to capture lessons learned'; category='Incident Analysis and Resolution' },

  @{ term='NOC'; definition='operations center monitoring infrastructure and network health'; category='Monitoring and Response' },
  @{ term='SOC'; definition='security operations center monitoring cyber threats and incidents'; category='Monitoring and Response' },
  @{ term='Observability'; definition='ability to infer system health from logs, metrics, and traces'; category='Monitoring and Response' },
  @{ term='Synthetic Monitoring'; definition='proactive scripted checks simulating user transactions'; category='Monitoring and Response' },
  @{ term='APM'; definition='application performance monitoring for latency and error visibility'; category='Monitoring and Response' },
  @{ term='Log Aggregation'; definition='centralized collection and indexing of log data'; category='Monitoring and Response' },
  @{ term='On-Call Rotation'; definition='scheduled support duty for after-hours incident handling'; category='Monitoring and Response' },
  @{ term='War Room'; definition='dedicated coordination channel during major incidents'; category='Monitoring and Response' },
  @{ term='Bridge Call'; definition='real-time conference for incident troubleshooting coordination'; category='Monitoring and Response' },
  @{ term='Status Page'; definition='public/internal dashboard communicating service health states'; category='Monitoring and Response' },

  @{ term='Patch Management'; definition='controlled deployment of updates to remediate vulnerabilities and defects'; category='Operational Resilience' },
  @{ term='Backup Verification'; definition='regular validation that backups are complete and restorable'; category='Operational Resilience' },
  @{ term='Disaster Recovery Drill'; definition='simulated failover exercise validating recovery readiness'; category='Operational Resilience' },
  @{ term='RTO'; definition='maximum acceptable time to restore critical service'; category='Operational Resilience' },
  @{ term='RPO'; definition='maximum acceptable data loss interval'; category='Operational Resilience' },
  @{ term='High Availability'; definition='architecture minimizing downtime through redundancy and failover'; category='Operational Resilience' },
  @{ term='Failover'; definition='automatic or manual switch to standby system on failure'; category='Operational Resilience' },
  @{ term='Capacity Planning'; definition='forecasting and provisioning resources for expected workloads'; category='Operational Resilience' },
  @{ term='Risk Register'; definition='tracked log of operational risks and mitigation plans'; category='Operational Resilience' },
  @{ term='Business Continuity'; definition='ability to maintain critical operations during disruptions'; category='Operational Resilience' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which IT operations concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which IT operations area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct IT operations term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT operations requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/it_operations_incident_management.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


