Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

function Shuffle($arr) { @($arr | Sort-Object { Get-Random }) }

$questions = @()
$id = 1

function Add-Mcq {
  param([string]$QuestionText,[string[]]$Options,[string]$Correct,[string]$Explanation)
  $answerIndex = [array]::IndexOf($Options, $Correct)
  if ($answerIndex -lt 0) { throw "Correct option missing: $QuestionText" }
  $script:questions += [ordered]@{
    id = $script:id
    question = $QuestionText
    options = @($Options[0],$Options[1],$Options[2],$Options[3])
    answer = $answerIndex
    explanation = $Explanation
  }
  $script:id += 1
}

$facts = @(
  @{ term='IaaS'; definition='cloud model providing virtualized compute, storage, networking'; category='Cloud Service Models' },
  @{ term='PaaS'; definition='cloud model providing managed runtime and development platform'; category='Cloud Service Models' },
  @{ term='SaaS'; definition='cloud model delivering complete software over internet'; category='Cloud Service Models' },
  @{ term='Public Cloud'; definition='cloud deployment shared across organizations via provider infrastructure'; category='Cloud Deployment Models' },
  @{ term='Private Cloud'; definition='cloud deployment dedicated to one organization'; category='Cloud Deployment Models' },
  @{ term='Hybrid Cloud'; definition='combination of private and public cloud environments'; category='Cloud Deployment Models' },
  @{ term='Multi-Cloud'; definition='use of services from more than one cloud provider'; category='Cloud Deployment Models' },
  @{ term='Virtualization'; definition='abstraction of physical hardware into virtual resources'; category='Cloud Fundamentals' },
  @{ term='Hypervisor'; definition='software layer that creates and runs virtual machines'; category='Cloud Fundamentals' },
  @{ term='Container'; definition='lightweight package containing app and dependencies'; category='Containerization' },
  @{ term='Docker'; definition='platform to build and run containers'; category='Containerization' },
  @{ term='Kubernetes'; definition='orchestration platform for managing containerized workloads'; category='Containerization' },
  @{ term='Pod'; definition='smallest deployable unit in Kubernetes'; category='Containerization' },
  @{ term='ReplicaSet'; definition='controller ensuring desired number of pod replicas'; category='Containerization' },
  @{ term='Deployment'; definition='Kubernetes object managing stateless application rollout'; category='Containerization' },
  @{ term='StatefulSet'; definition='Kubernetes workload object for stateful apps'; category='Containerization' },
  @{ term='DaemonSet'; definition='Kubernetes object running one pod per node'; category='Containerization' },
  @{ term='ConfigMap'; definition='Kubernetes object storing non-sensitive configuration'; category='Containerization' },
  @{ term='Secret'; definition='Kubernetes object storing sensitive configuration values'; category='Containerization' },
  @{ term='Ingress'; definition='Kubernetes API object controlling external HTTP/S routing'; category='Containerization' },
  @{ term='CI'; definition='practice of frequent code integration with automated builds/tests'; category='DevOps Practices' },
  @{ term='CD Delivery'; definition='practice ensuring software is always releasable'; category='DevOps Practices' },
  @{ term='CD Deployment'; definition='automatic release to production after successful pipeline'; category='DevOps Practices' },
  @{ term='Pipeline'; definition='automated sequence of build, test, and release stages'; category='DevOps Practices' },
  @{ term='Jenkins'; definition='popular automation server for CI/CD workflows'; category='DevOps Tooling' },
  @{ term='GitLab CI'; definition='integrated CI/CD platform in GitLab ecosystem'; category='DevOps Tooling' },
  @{ term='GitHub Actions'; definition='workflow automation platform integrated with GitHub'; category='DevOps Tooling' },
  @{ term='Artifact Repository'; definition='storage for build outputs and package artifacts'; category='DevOps Tooling' },
  @{ term='Terraform'; definition='infrastructure as code tool using declarative configuration'; category='Infrastructure as Code' },
  @{ term='Ansible'; definition='automation tool for configuration management and orchestration'; category='Infrastructure as Code' },
  @{ term='CloudFormation'; definition='AWS service for infrastructure provisioning from templates'; category='Infrastructure as Code' },
  @{ term='Immutable Infrastructure'; definition='approach replacing servers instead of modifying them'; category='Infrastructure as Code' },
  @{ term='Blue-Green Deployment'; definition='release strategy using two environments for switching traffic'; category='Release Strategies' },
  @{ term='Canary Deployment'; definition='release strategy gradually exposing new version to users'; category='Release Strategies' },
  @{ term='Rolling Deployment'; definition='release strategy updating instances incrementally'; category='Release Strategies' },
  @{ term='Rollback'; definition='reversion to previous stable version after failure'; category='Release Strategies' },
  @{ term='Observability'; definition='ability to infer system state using telemetry data'; category='Monitoring and Reliability' },
  @{ term='Monitoring'; definition='continuous tracking of system health and metrics'; category='Monitoring and Reliability' },
  @{ term='Logging'; definition='recording timestamped system and application events'; category='Monitoring and Reliability' },
  @{ term='Tracing'; definition='tracking request path across distributed services'; category='Monitoring and Reliability' },
  @{ term='Alerting'; definition='notifying teams when metrics cross defined thresholds'; category='Monitoring and Reliability' },
  @{ term='SLA'; definition='agreed service commitments between provider and customer'; category='Monitoring and Reliability' },
  @{ term='SLO'; definition='target reliability objective for service metrics'; category='Monitoring and Reliability' },
  @{ term='SLI'; definition='quantitative measurement of service behavior'; category='Monitoring and Reliability' },
  @{ term='Auto Scaling'; definition='automatic adjustment of resources based on demand'; category='Cloud Operations' },
  @{ term='Load Balancer'; definition='component distributing traffic across multiple servers'; category='Cloud Operations' },
  @{ term='Fault Tolerance'; definition='ability to continue operation despite component failures'; category='Cloud Operations' },
  @{ term='High Availability'; definition='design for minimal downtime and continuous service'; category='Cloud Operations' },
  @{ term='Disaster Recovery'; definition='plans and processes to restore services after major outage'; category='Cloud Operations' },
  @{ term='RPO'; definition='maximum acceptable data loss window'; category='Cloud Operations' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Cloud/DevOps concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which Cloud/DevOps area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct Cloud/DevOps term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT modernization requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/cloud_devops.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


