Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

function Shuffle($arr) {
  return @($arr | Sort-Object { Get-Random })
}

$questions = @()
$id = 1

function Add-Mcq {
  param(
    [string]$QuestionText,
    [string[]]$Options,
    [string]$Correct,
    [string]$Explanation
  )

  $answerIndex = [array]::IndexOf($Options, $Correct)
  if ($answerIndex -lt 0) {
    throw "Correct option not found for question: $QuestionText"
  }

  $script:questions += [ordered]@{
    id = $script:id
    question = $QuestionText
    options = @($Options[0], $Options[1], $Options[2], $Options[3])
    answer = $answerIndex
    explanation = $Explanation
  }

  $script:id += 1
}

$facts = @(
  @{ term='Process'; definition='program in execution with its own context'; category='Process Management' },
  @{ term='Thread'; definition='smallest unit of CPU execution within a process'; category='Process Management' },
  @{ term='Context Switch'; definition='saving and restoring CPU state between tasks'; category='Process Management' },
  @{ term='Scheduler'; definition='component that selects next process for CPU'; category='Process Management' },
  @{ term='Dispatcher'; definition='module that gives CPU control to selected process'; category='Process Management' },
  @{ term='Round Robin'; definition='scheduling algorithm with fixed time quantum'; category='CPU Scheduling' },
  @{ term='FCFS'; definition='scheduling policy that serves jobs by arrival order'; category='CPU Scheduling' },
  @{ term='SJF'; definition='scheduling algorithm choosing shortest burst first'; category='CPU Scheduling' },
  @{ term='SRTF'; definition='preemptive variant of shortest job scheduling'; category='CPU Scheduling' },
  @{ term='Priority Scheduling'; definition='algorithm selecting highest priority process'; category='CPU Scheduling' },
  @{ term='Starvation'; definition='indefinite waiting due to low scheduling priority'; category='CPU Scheduling' },
  @{ term='Aging'; definition='technique to prevent starvation by raising priority over time'; category='CPU Scheduling' },
  @{ term='Turnaround Time'; definition='total time from submission to completion'; category='CPU Scheduling' },
  @{ term='Waiting Time'; definition='time spent in ready queue before execution'; category='CPU Scheduling' },
  @{ term='Response Time'; definition='time until first CPU response after request'; category='CPU Scheduling' },
  @{ term='Deadlock'; definition='state where processes wait forever for held resources'; category='Concurrency' },
  @{ term='Mutual Exclusion'; definition='condition where resource can be used by one process at a time'; category='Concurrency' },
  @{ term='Hold and Wait'; definition='deadlock condition of holding one resource while waiting another'; category='Concurrency' },
  @{ term='No Preemption'; definition='deadlock condition where resources cannot be forcibly taken'; category='Concurrency' },
  @{ term='Circular Wait'; definition='deadlock condition where processes form waiting cycle'; category='Concurrency' },
  @{ term='Semaphore'; definition='integer-based synchronization primitive for shared resources'; category='Concurrency' },
  @{ term='Mutex'; definition='locking mechanism allowing only one thread in critical section'; category='Concurrency' },
  @{ term='Critical Section'; definition='code segment accessing shared data needing synchronization'; category='Concurrency' },
  @{ term='Race Condition'; definition='incorrect behavior caused by timing-dependent shared access'; category='Concurrency' },
  @{ term='Monitor'; definition='high-level synchronization construct with implicit mutual exclusion'; category='Concurrency' },
  @{ term='Virtual Memory'; definition='mechanism giving process illusion of large contiguous memory'; category='Memory Management' },
  @{ term='Paging'; definition='memory technique dividing address space into fixed-size pages'; category='Memory Management' },
  @{ term='Segmentation'; definition='memory management using variable-sized logical segments'; category='Memory Management' },
  @{ term='Page Fault'; definition='trap generated when referenced page is not in RAM'; category='Memory Management' },
  @{ term='TLB'; definition='cache storing recent page table translations'; category='Memory Management' },
  @{ term='Demand Paging'; definition='loading pages into memory only when referenced'; category='Memory Management' },
  @{ term='Thrashing'; definition='excessive paging that severely reduces CPU utilization'; category='Memory Management' },
  @{ term='Internal Fragmentation'; definition='unused memory space inside allocated fixed block'; category='Memory Management' },
  @{ term='External Fragmentation'; definition='free memory split into non-contiguous small blocks'; category='Memory Management' },
  @{ term='Buddy System'; definition='allocation scheme splitting memory into power-of-two blocks'; category='Memory Management' },
  @{ term='File System'; definition='method and structures for storing and retrieving files'; category='File Management' },
  @{ term='Inode'; definition='metadata structure in Unix file systems describing a file'; category='File Management' },
  @{ term='Journaling'; definition='file system technique logging changes before commit'; category='File Management' },
  @{ term='Directory'; definition='special file that maps names to file metadata entries'; category='File Management' },
  @{ term='Mount'; definition='operation attaching a file system to directory tree'; category='File Management' },
  @{ term='Boot Loader'; definition='program that loads kernel during system startup'; category='System Architecture' },
  @{ term='Kernel'; definition='core operating system component managing hardware and resources'; category='System Architecture' },
  @{ term='System Call'; definition='controlled interface between user programs and kernel'; category='System Architecture' },
  @{ term='Interrupt'; definition='signal causing CPU to suspend current flow for service routine'; category='System Architecture' },
  @{ term='Trap'; definition='software-generated interrupt for exceptions or system calls'; category='System Architecture' },
  @{ term='DMA'; definition='hardware feature transferring data without continuous CPU involvement'; category='I/O Management' },
  @{ term='Spooling'; definition='buffering technique queuing I/O jobs for shared device'; category='I/O Management' },
  @{ term='Buffering'; definition='temporary storage used to handle speed mismatch in I/O'; category='I/O Management' },
  @{ term='Caching'; definition='keeping frequently used data in faster storage for quick access'; category='I/O Management' },
  @{ term='Device Driver'; definition='software module enabling OS interaction with hardware device'; category='I/O Management' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']
  $definition = $fact['definition']
  $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Operating System concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term' in OS context?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' is primarily associated with which OS area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category in Operating Systems."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) {
    $pairs += "$($wf['term']) -> $definition"
  }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A system design requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) {
  throw "Expected 250 questions, generated $($questions.Count)."
}

$target = "data/topics/operating_system.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


