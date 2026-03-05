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
  @{ term='ALU'; definition='unit performing arithmetic and logical operations in CPU'; category='CPU Core' },
  @{ term='Control Unit'; definition='unit directing instruction execution and control signals'; category='CPU Core' },
  @{ term='Register'; definition='small fastest storage location inside CPU'; category='CPU Core' },
  @{ term='Program Counter'; definition='register holding address of next instruction'; category='CPU Core' },
  @{ term='Instruction Register'; definition='register storing currently fetched instruction'; category='CPU Core' },
  @{ term='Accumulator'; definition='register used for intermediate arithmetic results'; category='CPU Core' },
  @{ term='Cache Memory'; definition='small high-speed memory between CPU and RAM'; category='Memory Hierarchy' },
  @{ term='L1 Cache'; definition='closest and fastest cache level to CPU core'; category='Memory Hierarchy' },
  @{ term='L2 Cache'; definition='larger but slower cache than L1'; category='Memory Hierarchy' },
  @{ term='L3 Cache'; definition='shared cache across multiple cores in many CPUs'; category='Memory Hierarchy' },
  @{ term='RAM'; definition='volatile main memory used during program execution'; category='Memory Hierarchy' },
  @{ term='ROM'; definition='non-volatile memory storing firmware instructions'; category='Memory Hierarchy' },
  @{ term='Virtual Memory'; definition='technique extending memory using disk space'; category='Memory Hierarchy' },
  @{ term='Memory Latency'; definition='delay between memory request and data availability'; category='Memory Hierarchy' },
  @{ term='Memory Bandwidth'; definition='amount of data transferred per unit time'; category='Memory Hierarchy' },
  @{ term='Instruction Cycle'; definition='fetch-decode-execute sequence of CPU operation'; category='Instruction Processing' },
  @{ term='Pipelining'; definition='overlapping execution stages of multiple instructions'; category='Instruction Processing' },
  @{ term='Hazard'; definition='condition causing pipeline stall or incorrect execution'; category='Instruction Processing' },
  @{ term='Data Hazard'; definition='pipeline issue from instruction data dependency'; category='Instruction Processing' },
  @{ term='Control Hazard'; definition='pipeline issue caused by branch instructions'; category='Instruction Processing' },
  @{ term='Structural Hazard'; definition='pipeline issue due to hardware resource conflict'; category='Instruction Processing' },
  @{ term='Branch Prediction'; definition='technique guessing branch outcome to improve pipeline flow'; category='Instruction Processing' },
  @{ term='Superscalar'; definition='CPU design issuing multiple instructions per clock'; category='Instruction Processing' },
  @{ term='Out-of-Order Execution'; definition='CPU executing instructions as operands become available'; category='Instruction Processing' },
  @{ term='Clock Speed'; definition='number of CPU cycles executed per second'; category='Performance Metrics' },
  @{ term='CPI'; definition='average clock cycles per instruction'; category='Performance Metrics' },
  @{ term='MIPS'; definition='millions of instructions executed per second'; category='Performance Metrics' },
  @{ term='Throughput'; definition='number of tasks completed in given time'; category='Performance Metrics' },
  @{ term='Amdahl Law'; definition='speedup limitation due to non-parallelizable portion'; category='Performance Metrics' },
  @{ term='Multicore'; definition='processor containing multiple independent CPU cores'; category='Performance Metrics' },
  @{ term='Bus'; definition='communication pathway carrying data, address, and control signals'; category='Bus and I/O' },
  @{ term='Data Bus'; definition='bus carrying actual data between components'; category='Bus and I/O' },
  @{ term='Address Bus'; definition='bus carrying memory or I/O address information'; category='Bus and I/O' },
  @{ term='Control Bus'; definition='bus carrying read/write and control signals'; category='Bus and I/O' },
  @{ term='DMA'; definition='direct transfer between I/O and memory without CPU intervention'; category='Bus and I/O' },
  @{ term='Interrupt'; definition='signal requesting CPU attention for event handling'; category='Bus and I/O' },
  @{ term='Maskable Interrupt'; definition='interrupt that can be disabled by CPU'; category='Bus and I/O' },
  @{ term='Non-Maskable Interrupt'; definition='interrupt that cannot be ignored by CPU'; category='Bus and I/O' },
  @{ term='Memory-Mapped I/O'; definition='I/O method using memory address space for devices'; category='Bus and I/O' },
  @{ term='Port-Mapped I/O'; definition='I/O method using separate address space for devices'; category='Bus and I/O' },
  @{ term='RISC'; definition='instruction set philosophy with simple fixed-length instructions'; category='Architecture Design' },
  @{ term='CISC'; definition='instruction set philosophy with complex variable-length instructions'; category='Architecture Design' },
  @{ term='Harvard Architecture'; definition='separate memory paths for instructions and data'; category='Architecture Design' },
  @{ term='Von Neumann Architecture'; definition='single memory path shared by instructions and data'; category='Architecture Design' },
  @{ term='Microprogramming'; definition='control unit design using microinstructions in control memory'; category='Architecture Design' },
  @{ term='Endianness'; definition='byte order used for storing multi-byte data'; category='Architecture Design' },
  @{ term='Big Endian'; definition='storing most significant byte at lowest memory address'; category='Architecture Design' },
  @{ term='Little Endian'; definition='storing least significant byte at lowest memory address'; category='Architecture Design' },
  @{ term='Instruction Set Architecture'; definition='programmer-visible interface of processor operations'; category='Architecture Design' },
  @{ term='MMU'; definition='hardware unit translating virtual addresses to physical addresses'; category='Architecture Design' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']
  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Computer Architecture concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which architecture area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct architecture term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A system design requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/computer_architecture.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


