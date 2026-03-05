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
  @{ term='Cryptography'; definition='science of securing information using mathematical transformations'; category='Security Fundamentals' },
  @{ term='Plaintext'; definition='original readable data before encryption'; category='Security Fundamentals' },
  @{ term='Ciphertext'; definition='encrypted unreadable output produced by cryptographic algorithm'; category='Security Fundamentals' },
  @{ term='Encryption'; definition='process of converting plaintext into ciphertext'; category='Security Fundamentals' },
  @{ term='Decryption'; definition='process of converting ciphertext back into plaintext'; category='Security Fundamentals' },
  @{ term='Symmetric Encryption'; definition='encryption model using same key for encryption and decryption'; category='Cryptographic Models' },
  @{ term='Asymmetric Encryption'; definition='encryption model using public and private key pair'; category='Cryptographic Models' },
  @{ term='Session Key'; definition='temporary key used for a single communication session'; category='Cryptographic Models' },
  @{ term='Key Exchange'; definition='secure mechanism to share cryptographic keys between parties'; category='Cryptographic Models' },
  @{ term='Key Management'; definition='lifecycle management of creation, storage, rotation, and revocation of keys'; category='Cryptographic Models' },

  @{ term='AES'; definition='widely used symmetric block cipher standard'; category='Algorithms and Primitives' },
  @{ term='DES'; definition='legacy symmetric block cipher with 56-bit effective key'; category='Algorithms and Primitives' },
  @{ term='3DES'; definition='cipher applying DES algorithm three times for stronger security'; category='Algorithms and Primitives' },
  @{ term='RSA'; definition='asymmetric algorithm used for encryption and digital signatures'; category='Algorithms and Primitives' },
  @{ term='ECC'; definition='public-key cryptography based on elliptic curve mathematics'; category='Algorithms and Primitives' },
  @{ term='Diffie-Hellman'; definition='algorithm enabling secure key exchange over insecure channel'; category='Algorithms and Primitives' },
  @{ term='SHA-256'; definition='cryptographic hash function producing 256-bit digest'; category='Algorithms and Primitives' },
  @{ term='MD5'; definition='obsolete hash function vulnerable to collision attacks'; category='Algorithms and Primitives' },
  @{ term='HMAC'; definition='message authentication code using hash function and secret key'; category='Algorithms and Primitives' },
  @{ term='Salt'; definition='random value added before hashing to resist precomputed attacks'; category='Algorithms and Primitives' },

  @{ term='Digital Signature'; definition='cryptographic mechanism proving message authenticity and integrity'; category='Digital Trust' },
  @{ term='Non-Repudiation'; definition='assurance that sender cannot deny sent message'; category='Digital Trust' },
  @{ term='Integrity'; definition='security property ensuring data is not altered improperly'; category='Digital Trust' },
  @{ term='Confidentiality'; definition='security property preventing unauthorized data disclosure'; category='Digital Trust' },
  @{ term='Authentication'; definition='process of verifying identity of user or system'; category='Digital Trust' },
  @{ term='Authorization'; definition='process of verifying allowed actions after authentication'; category='Digital Trust' },
  @{ term='PKI'; definition='framework managing digital certificates and trust chains'; category='Digital Trust' },
  @{ term='Certificate Authority'; definition='trusted entity issuing and signing digital certificates'; category='Digital Trust' },
  @{ term='CSR'; definition='certificate signing request submitted to certificate authority'; category='Digital Trust' },
  @{ term='X.509 Certificate'; definition='standard format for public key digital certificates'; category='Digital Trust' },

  @{ term='TLS'; definition='protocol securing data in transit over networks'; category='Secure Communication' },
  @{ term='SSL'; definition='older predecessor protocol to TLS now deprecated'; category='Secure Communication' },
  @{ term='Handshake'; definition='initial negotiation phase establishing secure session parameters'; category='Secure Communication' },
  @{ term='Cipher Suite'; definition='set of cryptographic algorithms used in secure connection'; category='Secure Communication' },
  @{ term='Perfect Forward Secrecy'; definition='property where compromise of long-term key does not expose past sessions'; category='Secure Communication' },
  @{ term='VPN'; definition='encrypted tunnel for secure communication over public network'; category='Secure Communication' },
  @{ term='IPsec'; definition='suite securing IP communications using authentication and encryption'; category='Secure Communication' },
  @{ term='IKE'; definition='protocol for negotiating IPsec security associations'; category='Secure Communication' },
  @{ term='MACsec'; definition='layer-2 security protocol for Ethernet link encryption'; category='Secure Communication' },
  @{ term='SSH'; definition='secure protocol for remote administration and tunneling'; category='Secure Communication' },

  @{ term='Brute Force Attack'; definition='attack trying many key/password combinations exhaustively'; category='Threats and Defense' },
  @{ term='Dictionary Attack'; definition='attack trying likely passwords from predefined word lists'; category='Threats and Defense' },
  @{ term='Rainbow Table Attack'; definition='attack using precomputed hash lookup tables'; category='Threats and Defense' },
  @{ term='Man-in-the-Middle'; definition='attack intercepting and potentially altering communication'; category='Threats and Defense' },
  @{ term='Replay Attack'; definition='attack reusing captured valid data transmission'; category='Threats and Defense' },
  @{ term='Certificate Pinning'; definition='security technique binding app to expected certificate/public key'; category='Threats and Defense' },
  @{ term='Key Rotation'; definition='periodic replacement of cryptographic keys to reduce exposure'; category='Threats and Defense' },
  @{ term='Hardware Security Module'; definition='tamper-resistant device for secure cryptographic key operations'; category='Threats and Defense' },
  @{ term='Tokenization'; definition='replacing sensitive values with non-sensitive tokens'; category='Threats and Defense' },
  @{ term='Data at Rest Encryption'; definition='encryption applied to stored data to prevent unauthorized access'; category='Threats and Defense' }
)

$terms = @($facts | ForEach-Object { $_['term'] })
$definitions = @($facts | ForEach-Object { $_['definition'] })
$categories = @($facts | ForEach-Object { $_['category'] } | Select-Object -Unique)

foreach ($fact in $facts) {
  $term = $fact['term']; $definition = $fact['definition']; $category = $fact['category']

  $wrongTerms = @($terms | Where-Object { $_ -ne $term } | Get-Random -Count 3)
  $opts1 = Shuffle (@($term) + $wrongTerms)
  $q1 = "Which cryptography concept best matches: {0}?" -f $definition
  Add-Mcq -QuestionText $q1 -Options $opts1 -Correct $term -Explanation "$term is defined as: $definition."

  $wrongDefs = @($definitions | Where-Object { $_ -ne $definition } | Get-Random -Count 3)
  $opts2 = Shuffle (@($definition) + $wrongDefs)
  Add-Mcq -QuestionText "What is the most accurate description of '$term'?" -Options $opts2 -Correct $definition -Explanation "$term refers to: $definition."

  $wrongCats = @($categories | Where-Object { $_ -ne $category } | Get-Random -Count 3)
  $opts3 = Shuffle (@($category) + $wrongCats)
  Add-Mcq -QuestionText "'$term' belongs mainly to which cryptography/security area?" -Options $opts3 -Correct $category -Explanation "$term is mainly part of $category."

  $wrongPairsFacts = @($facts | Where-Object { $_['term'] -ne $term } | Get-Random -Count 3)
  $correctPair = "$term -> $definition"
  $pairs = @($correctPair)
  foreach ($wf in $wrongPairsFacts) { $pairs += "$($wf['term']) -> $definition" }
  $opts4 = Shuffle $pairs
  Add-Mcq -QuestionText "Identify the correct cryptography term-definition mapping." -Options $opts4 -Correct $correctPair -Explanation "Only '$correctPair' is correctly mapped."

  $scenario = "A Bank SO IT security requirement states: {0}. Which concept should be selected?" -f $definition
  $opts5 = Shuffle (@($term) + $wrongTerms)
  Add-Mcq -QuestionText $scenario -Options $opts5 -Correct $term -Explanation "The requirement directly points to $term."
}

if ($questions.Count -ne 250) { throw "Expected 250 questions, generated $($questions.Count)." }

$target = "data/topics/cryptography_digital_security.json"
[ordered]@{ questions = @($questions) } | ConvertTo-Json -Depth 8 | Set-Content -Path $target -Encoding utf8
Write-Output "Generated $($questions.Count) questions in $target"


