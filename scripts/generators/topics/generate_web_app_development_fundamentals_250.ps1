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
  @{ term='HTML'; definition='markup language used to structure web content'; category='Web Basics' },
  @{ term='CSS'; definition='style sheet language used to design web presentation'; category='Web Basics' },
  @{ term='JavaScript'; definition='programming language for dynamic web behavior'; category='Web Basics' },
  @{ term='DOM'; definition='tree representation of HTML document for script interaction'; category='Web Basics' },
  @{ term='HTTP'; definition='application protocol for web communication'; category='Web Basics' },
  @{ term='HTTPS'; definition='secure HTTP communication over TLS'; category='Web Basics' },
  @{ term='URL'; definition='uniform resource locator specifying web resource address'; category='Web Basics' },
  @{ term='DNS'; definition='system translating domain names into IP addresses'; category='Web Basics' },
  @{ term='Cookie'; definition='small browser-stored data sent with HTTP requests'; category='Web Basics' },
  @{ term='Session'; definition='server-side state maintained for user interaction'; category='Web Basics' },

  @{ term='GET'; definition='HTTP method used to retrieve resource data'; category='HTTP Methods and Status' },
  @{ term='POST'; definition='HTTP method used to create or submit resource data'; category='HTTP Methods and Status' },
  @{ term='PUT'; definition='HTTP method used to replace resource representation'; category='HTTP Methods and Status' },
  @{ term='PATCH'; definition='HTTP method used to partially update resource'; category='HTTP Methods and Status' },
  @{ term='DELETE'; definition='HTTP method used to remove resource'; category='HTTP Methods and Status' },
  @{ term='Status Code 200'; definition='HTTP response code indicating successful request'; category='HTTP Methods and Status' },
  @{ term='Status Code 201'; definition='HTTP response code indicating resource created'; category='HTTP Methods and Status' },
  @{ term='Status Code 400'; definition='HTTP response code indicating bad client request'; category='HTTP Methods and Status' },
  @{ term='Status Code 401'; definition='HTTP response code indicating unauthorized access'; category='HTTP Methods and Status' },
  @{ term='Status Code 404'; definition='HTTP response code indicating resource not found'; category='HTTP Methods and Status' },

  @{ term='REST API'; definition='architectural style using stateless resource-based endpoints'; category='API Fundamentals' },
  @{ term='JSON'; definition='lightweight data-interchange format using key-value pairs'; category='API Fundamentals' },
  @{ term='XML'; definition='markup format for structured data exchange'; category='API Fundamentals' },
  @{ term='Endpoint'; definition='specific URL where API resource can be accessed'; category='API Fundamentals' },
  @{ term='Idempotency'; definition='property where repeated request yields same effect'; category='API Fundamentals' },
  @{ term='Authentication'; definition='process of verifying user or client identity'; category='API Fundamentals' },
  @{ term='Authorization'; definition='process of checking permitted actions for identity'; category='API Fundamentals' },
  @{ term='Bearer Token'; definition='access token included in authorization header'; category='API Fundamentals' },
  @{ term='Rate Limiting'; definition='control restricting number of requests in timeframe'; category='API Fundamentals' },
  @{ term='Pagination'; definition='technique splitting large API response into pages'; category='API Fundamentals' },

  @{ term='Responsive Design'; definition='design approach adapting UI to different screen sizes'; category='Frontend Engineering' },
  @{ term='Viewport'; definition='visible area of web page on a device'; category='Frontend Engineering' },
  @{ term='Flexbox'; definition='CSS layout model for one-dimensional alignment'; category='Frontend Engineering' },
  @{ term='CSS Grid'; definition='CSS layout model for two-dimensional page structure'; category='Frontend Engineering' },
  @{ term='Media Query'; definition='CSS rule applying styles based on device conditions'; category='Frontend Engineering' },
  @{ term='Accessibility'; definition='practice of making web usable for all users'; category='Frontend Engineering' },
  @{ term='ARIA'; definition='attributes improving accessibility for assistive technologies'; category='Frontend Engineering' },
  @{ term='Progressive Enhancement'; definition='building core functionality first then advanced features'; category='Frontend Engineering' },
  @{ term='Lazy Loading'; definition='deferring non-critical resource loading until needed'; category='Frontend Engineering' },
  @{ term='Minification'; definition='removal of unnecessary characters to reduce file size'; category='Frontend Engineering' },

  @{ term='Same-Origin Policy'; definition='browser security rule restricting cross-origin interactions'; category='Web Security Fundamentals' },
  @{ term='CORS'; definition='mechanism allowing controlled cross-origin HTTP requests'; category='Web Security Fundamentals' },
  @{ term='XSS'; definition='attack injecting malicious scripts into trusted pages'; category='Web Security Fundamentals' },
  @{ term='CSRF'; definition='attack forcing authenticated user to perform unwanted action'; category='Web Security Fundamentals' },
  @{ term='SQL Injection'; definition='attack manipulating SQL queries through unsanitized input'; category='Web Security Fundamentals' },
  @{ term='Content Security Policy'; definition='security header restricting allowed content sources'; category='Web Security Fundamentals' },
  @{ term='Input Sanitization'; definition='cleaning untrusted input to prevent injection'; category='Web Security Fundamentals' },
  @{ term='Output Encoding'; definition='escaping output context to prevent script execution'; category='Web Security Fundamentals' },
  @{ term='TLS Certificate'; definition='digital certificate enabling encrypted HTTPS communication'; category='Web Security Fundamentals' },
  @{ term='HSTS'; definition='header enforcing HTTPS-only communication for domain'; category='Web Security Fundamentals' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which Web/App Development concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which web/application area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct web/app term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT application requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/web_app_development_fundamentals.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


