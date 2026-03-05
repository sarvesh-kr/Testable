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
  @{ term='Array'; definition='contiguous collection of elements accessed by index'; category='Core Data Structures' },
  @{ term='Linked List'; definition='linear structure of nodes connected via pointers'; category='Core Data Structures' },
  @{ term='Doubly Linked List'; definition='linked list where each node has next and previous pointers'; category='Core Data Structures' },
  @{ term='Stack'; definition='LIFO structure supporting push and pop operations'; category='Core Data Structures' },
  @{ term='Queue'; definition='FIFO structure supporting enqueue and dequeue operations'; category='Core Data Structures' },
  @{ term='Deque'; definition='double-ended queue allowing insertion and deletion at both ends'; category='Core Data Structures' },
  @{ term='Hash Table'; definition='key-value structure using hash function for indexing'; category='Core Data Structures' },
  @{ term='Heap'; definition='complete binary tree satisfying heap order property'; category='Core Data Structures' },
  @{ term='Binary Search Tree'; definition='binary tree where left keys are smaller and right keys larger'; category='Core Data Structures' },
  @{ term='Trie'; definition='prefix tree optimized for string retrieval'; category='Core Data Structures' },

  @{ term='Graph'; definition='set of vertices connected by edges'; category='Graph Concepts' },
  @{ term='Directed Graph'; definition='graph where edges have direction'; category='Graph Concepts' },
  @{ term='Undirected Graph'; definition='graph where edges have no direction'; category='Graph Concepts' },
  @{ term='Weighted Graph'; definition='graph where edges carry associated weights'; category='Graph Concepts' },
  @{ term='Breadth First Search'; definition='graph traversal exploring neighbors level by level'; category='Graph Algorithms' },
  @{ term='Depth First Search'; definition='graph traversal exploring path deeply before backtracking'; category='Graph Algorithms' },
  @{ term='Dijkstra Algorithm'; definition='shortest path algorithm for non-negative edge weights'; category='Graph Algorithms' },
  @{ term='Bellman-Ford Algorithm'; definition='shortest path algorithm handling negative edge weights'; category='Graph Algorithms' },
  @{ term='Floyd-Warshall Algorithm'; definition='all-pairs shortest path dynamic programming algorithm'; category='Graph Algorithms' },
  @{ term='Topological Sort'; definition='linear ordering of DAG vertices by dependency'; category='Graph Algorithms' },

  @{ term='Recursion'; definition='problem-solving approach where function calls itself'; category='Algorithmic Techniques' },
  @{ term='Dynamic Programming'; definition='optimization technique using overlapping subproblems and memoization'; category='Algorithmic Techniques' },
  @{ term='Greedy Algorithm'; definition='approach making locally optimal choices at each step'; category='Algorithmic Techniques' },
  @{ term='Divide and Conquer'; definition='technique splitting problem into smaller independent subproblems'; category='Algorithmic Techniques' },
  @{ term='Backtracking'; definition='search technique trying possibilities and undoing invalid choices'; category='Algorithmic Techniques' },
  @{ term='Branch and Bound'; definition='optimization technique pruning branches by bounds'; category='Algorithmic Techniques' },
  @{ term='Sliding Window'; definition='technique maintaining window over sequence for efficient computation'; category='Algorithmic Techniques' },
  @{ term='Two Pointers'; definition='technique using two indices moving through data structure'; category='Algorithmic Techniques' },
  @{ term='Binary Search'; definition='search algorithm halving sorted search space each step'; category='Algorithmic Techniques' },
  @{ term='Prefix Sum'; definition='precomputed cumulative sums enabling range query optimization'; category='Algorithmic Techniques' },

  @{ term='Bubble Sort'; definition='sorting algorithm repeatedly swapping adjacent out-of-order elements'; category='Sorting and Searching' },
  @{ term='Selection Sort'; definition='sorting algorithm selecting minimum and placing it in order'; category='Sorting and Searching' },
  @{ term='Insertion Sort'; definition='sorting algorithm building sorted list by insertion'; category='Sorting and Searching' },
  @{ term='Merge Sort'; definition='stable divide-and-conquer sorting algorithm with O(n log n) time'; category='Sorting and Searching' },
  @{ term='Quick Sort'; definition='divide-and-conquer sorting algorithm around pivot partition'; category='Sorting and Searching' },
  @{ term='Heap Sort'; definition='sorting algorithm using heap structure for ordering'; category='Sorting and Searching' },
  @{ term='Counting Sort'; definition='non-comparison sort for bounded integer ranges'; category='Sorting and Searching' },
  @{ term='Radix Sort'; definition='non-comparison sort processing digits by significance'; category='Sorting and Searching' },
  @{ term='Linear Search'; definition='sequential search scanning each element until target found'; category='Sorting and Searching' },
  @{ term='Interpolation Search'; definition='search estimating likely position in uniformly distributed sorted data'; category='Sorting and Searching' },

  @{ term='Time Complexity'; definition='asymptotic measure of runtime growth with input size'; category='Complexity Analysis' },
  @{ term='Space Complexity'; definition='asymptotic measure of memory usage growth with input size'; category='Complexity Analysis' },
  @{ term='Big O Notation'; definition='upper bound notation for algorithm growth rate'; category='Complexity Analysis' },
  @{ term='Omega Notation'; definition='lower bound notation for algorithm growth rate'; category='Complexity Analysis' },
  @{ term='Theta Notation'; definition='tight bound notation for algorithm growth rate'; category='Complexity Analysis' },
  @{ term='Amortized Analysis'; definition='average cost analysis over sequence of operations'; category='Complexity Analysis' },
  @{ term='Best Case'; definition='minimum operations required by algorithm for input'; category='Complexity Analysis' },
  @{ term='Average Case'; definition='expected operations over distribution of inputs'; category='Complexity Analysis' },
  @{ term='Worst Case'; definition='maximum operations required by algorithm for input'; category='Complexity Analysis' },
  @{ term='NP-Complete'; definition='class of decision problems verifiable in polynomial time and NP-hard'; category='Complexity Analysis' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which DSA concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which DSA area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct DSA term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT technical requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/data_structure_algorithm.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


