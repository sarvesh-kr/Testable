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
  @{ term='Monitoring'; definition='continuous observation of system and application health metrics'; category='Monitoring Fundamentals' },
  @{ term='Logging'; definition='capturing timestamped records of system and application events'; category='Monitoring Fundamentals' },
  @{ term='Metrics'; definition='numeric measurements representing system behavior over time'; category='Monitoring Fundamentals' },
  @{ term='Trace'; definition='end-to-end record of request journey across services'; category='Monitoring Fundamentals' },
  @{ term='Observability'; definition='ability to infer internal state from external telemetry'; category='Monitoring Fundamentals' },
  @{ term='Dashboard'; definition='visual interface summarizing key operational indicators'; category='Monitoring Fundamentals' },
  @{ term='Alert'; definition='notification triggered when metric/log rule condition is met'; category='Monitoring Fundamentals' },
  @{ term='Threshold'; definition='defined value boundary used for alert triggering'; category='Monitoring Fundamentals' },
  @{ term='Baseline'; definition='normal behavior reference for anomaly detection'; category='Monitoring Fundamentals' },
  @{ term='SLO'; definition='target reliability objective for service performance'; category='Monitoring Fundamentals' },

  @{ term='Error Rate'; definition='percentage of requests resulting in failures'; category='Service Reliability Metrics' },
  @{ term='Latency'; definition='time taken to complete a request or operation'; category='Service Reliability Metrics' },
  @{ term='Throughput'; definition='number of transactions processed per unit time'; category='Service Reliability Metrics' },
  @{ term='Availability'; definition='percentage of time service remains operational'; category='Service Reliability Metrics' },
  @{ term='MTTD'; definition='mean time to detect incident occurrence'; category='Service Reliability Metrics' },
  @{ term='MTTR'; definition='mean time to restore service after failure'; category='Service Reliability Metrics' },
  @{ term='P95 Latency'; definition='latency value below which 95 percent requests complete'; category='Service Reliability Metrics' },
  @{ term='P99 Latency'; definition='latency value below which 99 percent requests complete'; category='Service Reliability Metrics' },
  @{ term='Apdex'; definition='index measuring user satisfaction based on response times'; category='Service Reliability Metrics' },
  @{ term='SLA'; definition='formal agreement defining service performance commitments'; category='Service Reliability Metrics' },

  @{ term='Structured Logging'; definition='logging format with parseable key-value fields'; category='Log Management' },
  @{ term='Log Aggregation'; definition='centralized collection of logs from multiple sources'; category='Log Management' },
  @{ term='Log Parsing'; definition='process extracting fields from raw log messages'; category='Log Management' },
  @{ term='Log Retention'; definition='policy governing duration of log storage'; category='Log Management' },
  @{ term='Log Rotation'; definition='scheduled archival and replacement of active log files'; category='Log Management' },
  @{ term='Correlation ID'; definition='unique identifier linking related logs across services'; category='Log Management' },
  @{ term='Audit Log'; definition='immutable record of security and administrative actions'; category='Log Management' },
  @{ term='Syslog'; definition='standard protocol for forwarding log messages'; category='Log Management' },
  @{ term='Log Sampling'; definition='selective log capture to reduce volume and cost'; category='Log Management' },
  @{ term='Sensitive Data Masking'; definition='obscuring confidential fields in log output'; category='Log Management' },

  @{ term='Prometheus'; definition='time-series monitoring system with pull-based scraping'; category='Monitoring Tooling' },
  @{ term='Grafana'; definition='visualization platform for metrics and logs dashboards'; category='Monitoring Tooling' },
  @{ term='ELK Stack'; definition='Elasticsearch, Logstash, Kibana stack for log analytics'; category='Monitoring Tooling' },
  @{ term='OpenTelemetry'; definition='standard framework for metrics, traces, and logs instrumentation'; category='Monitoring Tooling' },
  @{ term='APM'; definition='application performance monitoring for code-level diagnostics'; category='Monitoring Tooling' },
  @{ term='Synthetic Monitoring'; definition='scripted checks simulating user interactions periodically'; category='Monitoring Tooling' },
  @{ term='Real User Monitoring'; definition='collection of performance data from actual user sessions'; category='Monitoring Tooling' },
  @{ term='Alertmanager'; definition='component routing and deduplicating monitoring alerts'; category='Monitoring Tooling' },
  @{ term='On-Call'; definition='assigned engineer responsible for incident response during shift'; category='Monitoring Tooling' },
  @{ term='Runbook Automation'; definition='automated execution of predefined remediation procedures'; category='Monitoring Tooling' },

  @{ term='Anomaly Detection'; definition='identification of deviations from normal telemetry patterns'; category='Incident Detection and Response' },
  @{ term='Incident Triage'; definition='initial assessment to classify and prioritize alerts'; category='Incident Detection and Response' },
  @{ term='False Positive'; definition='alert indicating issue when none exists'; category='Incident Detection and Response' },
  @{ term='False Negative'; definition='missed detection where real issue was not alerted'; category='Incident Detection and Response' },
  @{ term='Noise Reduction'; definition='techniques reducing redundant or low-value alerts'; category='Incident Detection and Response' },
  @{ term='Alert Fatigue'; definition='desensitization due to excessive non-actionable alerts'; category='Incident Detection and Response' },
  @{ term='Escalation Policy'; definition='rules defining whom to notify when incidents persist'; category='Incident Detection and Response' },
  @{ term='War Room'; definition='coordinated collaboration channel during major incident'; category='Incident Detection and Response' },
  @{ term='Postmortem'; definition='blameless analysis documenting cause, impact, and improvements'; category='Incident Detection and Response' },
  @{ term='RCA'; definition='root cause analysis identifying underlying incident reason'; category='Incident Detection and Response' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which monitoring/logging concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which monitoring/logging area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct monitoring/logging term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT operations requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/monitoring_logging.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


