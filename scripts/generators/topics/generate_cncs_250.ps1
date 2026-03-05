Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\.."))

function Shuffle($arr) {
  return @($arr | Sort-Object { Get-Random })
}

$questions = @()
$id = 1

function Add-McqQuestion {
  param(
    [string]$QuestionText,
    [string[]]$Options,
    [string]$Correct,
    [string]$Explanation
  )

  $script:questions += [ordered]@{
    id = $script:id
    question = $QuestionText
    options = @($Options[0], $Options[1], $Options[2], $Options[3])
    answer = [array]::IndexOf($Options, $Correct)
    explanation = $Explanation
  }

  $script:id += 1
}

$servicePorts = @(
  @{ service='FTP (Data)'; port='20' },
  @{ service='FTP (Control)'; port='21' },
  @{ service='SSH'; port='22' },
  @{ service='Telnet'; port='23' },
  @{ service='SMTP'; port='25' },
  @{ service='DNS'; port='53' },
  @{ service='DHCP Server'; port='67' },
  @{ service='DHCP Client'; port='68' },
  @{ service='TFTP'; port='69' },
  @{ service='HTTP'; port='80' },
  @{ service='POP3'; port='110' },
  @{ service='NTP'; port='123' },
  @{ service='IMAP'; port='143' },
  @{ service='SNMP'; port='161' },
  @{ service='SNMP Trap'; port='162' },
  @{ service='BGP'; port='179' },
  @{ service='LDAP'; port='389' },
  @{ service='HTTPS'; port='443' },
  @{ service='SMB'; port='445' },
  @{ service='SMTPS'; port='465' },
  @{ service='Syslog'; port='514' },
  @{ service='LDAPS'; port='636' },
  @{ service='IMAPS'; port='993' },
  @{ service='POP3S'; port='995' },
  @{ service='Microsoft SQL Server'; port='1433' },
  @{ service='Oracle Listener'; port='1521' },
  @{ service='NFS'; port='2049' },
  @{ service='SIP'; port='5060' },
  @{ service='SIPS'; port='5061' },
  @{ service='MySQL'; port='3306' },
  @{ service='RDP'; port='3389' },
  @{ service='PostgreSQL'; port='5432' },
  @{ service='VNC'; port='5900' },
  @{ service='WinRM (HTTP)'; port='5985' },
  @{ service='WinRM (HTTPS)'; port='5986' },
  @{ service='Kerberos'; port='88' },
  @{ service='L2TP'; port='1701' },
  @{ service='PPTP'; port='1723' },
  @{ service='RADIUS Authentication'; port='1812' },
  @{ service='RADIUS Accounting'; port='1813' },
  @{ service='ISAKMP/IKE'; port='500' },
  @{ service='IPsec NAT-T'; port='4500' },
  @{ service='MQTT'; port='1883' },
  @{ service='MQTTS'; port='8883' },
  @{ service='DNS over TLS'; port='853' },
  @{ service='Redis'; port='6379' },
  @{ service='Kubernetes API Server'; port='6443' },
  @{ service='Docker (TLS)'; port='2376' },
  @{ service='etcd Client'; port='2379' },
  @{ service='Rsync'; port='873' },
  @{ service='AFP'; port='548' },
  @{ service='LDAP Global Catalog'; port='3268' },
  @{ service='LDAP Global Catalog SSL'; port='3269' }
)

$portPool = @($servicePorts | ForEach-Object { $_.port } | Select-Object -Unique)
foreach ($item in $servicePorts) {
  $wrong = @($portPool | Where-Object { $_ -ne $item.port } | Get-Random -Count 3)
  $opts = Shuffle (@($item.port) + $wrong)
  Add-McqQuestion -QuestionText "What is the default port used by $($item.service)?" -Options $opts -Correct $item.port -Explanation "$($item.service) commonly uses port $($item.port) in standard network configurations."
}

$acronyms = @(
  @{ short='OSI'; full='Open Systems Interconnection' },
  @{ short='TCP'; full='Transmission Control Protocol' },
  @{ short='UDP'; full='User Datagram Protocol' },
  @{ short='IP'; full='Internet Protocol' },
  @{ short='ICMP'; full='Internet Control Message Protocol' },
  @{ short='ARP'; full='Address Resolution Protocol' },
  @{ short='NAT'; full='Network Address Translation' },
  @{ short='PAT'; full='Port Address Translation' },
  @{ short='VLAN'; full='Virtual Local Area Network' },
  @{ short='VPN'; full='Virtual Private Network' },
  @{ short='IDS'; full='Intrusion Detection System' },
  @{ short='IPS'; full='Intrusion Prevention System' },
  @{ short='DLP'; full='Data Loss Prevention' },
  @{ short='SIEM'; full='Security Information and Event Management' },
  @{ short='SOC'; full='Security Operations Center' },
  @{ short='CSIRT'; full='Computer Security Incident Response Team' },
  @{ short='MFA'; full='Multi-Factor Authentication' },
  @{ short='OTP'; full='One-Time Password' },
  @{ short='PKI'; full='Public Key Infrastructure' },
  @{ short='CA'; full='Certificate Authority' },
  @{ short='CRL'; full='Certificate Revocation List' },
  @{ short='OCSP'; full='Online Certificate Status Protocol' },
  @{ short='AES'; full='Advanced Encryption Standard' },
  @{ short='RSA'; full='Rivest-Shamir-Adleman' },
  @{ short='DES'; full='Data Encryption Standard' },
  @{ short='HMAC'; full='Hash-based Message Authentication Code' },
  @{ short='SHA'; full='Secure Hash Algorithm' },
  @{ short='DDoS'; full='Distributed Denial of Service' },
  @{ short='XSS'; full='Cross-Site Scripting' },
  @{ short='CSRF'; full='Cross-Site Request Forgery' },
  @{ short='SQL'; full='Structured Query Language' },
  @{ short='WAF'; full='Web Application Firewall' },
  @{ short='UTM'; full='Unified Threat Management' },
  @{ short='BGP'; full='Border Gateway Protocol' },
  @{ short='OSPF'; full='Open Shortest Path First' },
  @{ short='RIP'; full='Routing Information Protocol' },
  @{ short='STP'; full='Spanning Tree Protocol' },
  @{ short='RSTP'; full='Rapid Spanning Tree Protocol' },
  @{ short='MSTP'; full='Multiple Spanning Tree Protocol' },
  @{ short='QoS'; full='Quality of Service' },
  @{ short='SLA'; full='Service Level Agreement' },
  @{ short='RTO'; full='Recovery Time Objective' },
  @{ short='RPO'; full='Recovery Point Objective' },
  @{ short='DR'; full='Disaster Recovery' },
  @{ short='BCP'; full='Business Continuity Plan' },
  @{ short='KYC'; full='Know Your Customer' },
  @{ short='SWIFT'; full='Society for Worldwide Interbank Financial Telecommunication' },
  @{ short='NEFT'; full='National Electronic Funds Transfer' },
  @{ short='RTGS'; full='Real Time Gross Settlement' },
  @{ short='IMPS'; full='Immediate Payment Service' },
  @{ short='UPI'; full='Unified Payments Interface' },
  @{ short='PCI DSS'; full='Payment Card Industry Data Security Standard' },
  @{ short='ISMS'; full='Information Security Management System' },
  @{ short='EDR'; full='Endpoint Detection and Response' },
  @{ short='NDR'; full='Network Detection and Response' },
  @{ short='UEBA'; full='User and Entity Behavior Analytics' },
  @{ short='IAM'; full='Identity and Access Management' },
  @{ short='PAM'; full='Privileged Access Management' },
  @{ short='SASE'; full='Secure Access Service Edge' },
  @{ short='ZTNA'; full='Zero Trust Network Access' },
  @{ short='SDN'; full='Software-Defined Networking' },
  @{ short='NFV'; full='Network Functions Virtualization' },
  @{ short='AAA'; full='Authentication Authorization and Accounting' },
  @{ short='TACACS'; full='Terminal Access Controller Access-Control System' },
  @{ short='NAC'; full='Network Access Control' },
  @{ short='MPLS'; full='Multiprotocol Label Switching' },
  @{ short='CVE'; full='Common Vulnerabilities and Exposures' },
  @{ short='CWE'; full='Common Weakness Enumeration' },
  @{ short='MITM'; full='Man-in-the-Middle' },
  @{ short='MAC'; full='Media Access Control' }
)

$fullPool = @($acronyms | ForEach-Object { $_.full })
foreach ($item in $acronyms) {
  $wrong = @($fullPool | Where-Object { $_ -ne $item.full } | Get-Random -Count 3)
  $opts = Shuffle (@($item.full) + $wrong)
  Add-McqQuestion -QuestionText "What is the full form of $($item.short)?" -Options $opts -Correct $item.full -Explanation "$($item.short) expands to $($item.full)."
}

$protocolPurpose = @(
  @{ protocol='ARP'; purpose='resolving IPv4 address to MAC address in a LAN' },
  @{ protocol='RARP'; purpose='obtaining IP address from MAC address (legacy)' },
  @{ protocol='ICMP'; purpose='sending error reports and diagnostics like ping' },
  @{ protocol='DHCP'; purpose='automatic assignment of IP configuration parameters' },
  @{ protocol='DNS'; purpose='resolving domain names to IP addresses' },
  @{ protocol='NTP'; purpose='time synchronization across network devices' },
  @{ protocol='SNMP'; purpose='monitoring and managing network devices' },
  @{ protocol='Syslog'; purpose='centralized transmission of log messages' },
  @{ protocol='BGP'; purpose='routing between autonomous systems on the Internet' },
  @{ protocol='OSPF'; purpose='link-state interior routing within an enterprise' },
  @{ protocol='RIP'; purpose='distance-vector interior routing using hop count' },
  @{ protocol='EIGRP'; purpose='advanced distance-vector routing in Cisco environments' },
  @{ protocol='MPLS'; purpose='label-based forwarding across provider networks' },
  @{ protocol='GRE'; purpose='tunneling protocols over IP networks' },
  @{ protocol='IPsec'; purpose='providing confidentiality and integrity at network layer' },
  @{ protocol='SSL/TLS'; purpose='encrypting communication channels over TCP' },
  @{ protocol='SSH'; purpose='secure command-line remote administration' },
  @{ protocol='SFTP'; purpose='secure file transfer over SSH channel' },
  @{ protocol='FTPS'; purpose='FTP communication secured using TLS' },
  @{ protocol='TFTP'; purpose='simple file transfer without authentication' },
  @{ protocol='HTTP'; purpose='transferring hypertext between client and web server' },
  @{ protocol='HTTPS'; purpose='secure web communication using TLS' },
  @{ protocol='POP3'; purpose='downloading emails from server to client' },
  @{ protocol='IMAP'; purpose='synchronizing email while retaining server-side copies' },
  @{ protocol='SMTP'; purpose='sending email between clients and mail servers' },
  @{ protocol='LDAP'; purpose='directory lookup and authentication queries' },
  @{ protocol='RADIUS'; purpose='AAA services for remote network access' },
  @{ protocol='TACACS+'; purpose='centralized AAA with command authorization' },
  @{ protocol='Kerberos'; purpose='ticket-based network authentication' },
  @{ protocol='802.1X'; purpose='port-based network access control for endpoints' },
  @{ protocol='STP'; purpose='preventing loops in switched Ethernet topology' },
  @{ protocol='RSTP'; purpose='faster convergence loop prevention in switched networks' },
  @{ protocol='MSTP'; purpose='running multiple spanning tree instances on VLAN groups' },
  @{ protocol='VTP'; purpose='propagating VLAN configuration across switches' },
  @{ protocol='VRRP'; purpose='providing first-hop redundancy for gateway routers' },
  @{ protocol='HSRP'; purpose='Cisco-based first-hop gateway redundancy' },
  @{ protocol='LACP'; purpose='aggregating multiple physical links into one logical link' },
  @{ protocol='PPTP'; purpose='legacy VPN tunneling over PPP' },
  @{ protocol='L2TP'; purpose='layer 2 tunneling often combined with IPsec' },
  @{ protocol='SIP'; purpose='establishing and managing VoIP sessions' },
  @{ protocol='RTP'; purpose='delivering real-time audio or video streams' },
  @{ protocol='RTCP'; purpose='monitoring quality statistics of RTP streams' },
  @{ protocol='NFS'; purpose='file sharing between Unix/Linux systems' },
  @{ protocol='SMB/CIFS'; purpose='file and printer sharing in Windows networks' },
  @{ protocol='iSCSI'; purpose='transporting SCSI commands over IP storage networks' },
  @{ protocol='Fibre Channel'; purpose='high-speed SAN connectivity for storage' },
  @{ protocol='VXLAN'; purpose='extending layer 2 segments over layer 3 networks' },
  @{ protocol='CAPWAP'; purpose='communication between wireless APs and controllers' },
  @{ protocol='WPA2'; purpose='securing wireless LAN with AES-CCMP' },
  @{ protocol='WPA3'; purpose='stronger wireless security with SAE authentication' },
  @{ protocol='IP SLA'; purpose='proactive network performance measurement' },
  @{ protocol='NetFlow'; purpose='collecting and analyzing IP traffic flow metadata' },
  @{ protocol='sFlow'; purpose='packet sampling for traffic visibility' },
  @{ protocol='SPAN'; purpose='mirroring switch traffic to monitoring tools' },
  @{ protocol='LLDP'; purpose='vendor-neutral neighbor discovery on LAN' },
  @{ protocol='CDP'; purpose='Cisco neighbor discovery protocol' },
  @{ protocol='PoE'; purpose='delivering power over Ethernet cables to devices' },
  @{ protocol='Modbus TCP'; purpose='industrial device communication over TCP/IP' },
  @{ protocol='MQTT'; purpose='lightweight publish-subscribe messaging for IoT' },
  @{ protocol='AMQP'; purpose='reliable message-oriented middleware communication' },
  @{ protocol='WebSocket'; purpose='full-duplex persistent communication over single TCP connection' },
  @{ protocol='QUIC'; purpose='secure low-latency transport over UDP for modern web traffic' },
  @{ protocol='DNSSEC'; purpose='authenticating DNS response integrity' },
  @{ protocol='OCSP'; purpose='real-time certificate revocation status checking' },
  @{ protocol='CRL'; purpose='publishing revoked certificates list' },
  @{ protocol='PKI'; purpose='managing digital certificates and trust chains' },
  @{ protocol='SIEM'; purpose='correlating security events from multiple sources' },
  @{ protocol='SOAR'; purpose='automating security response workflows' },
  @{ protocol='EDR'; purpose='detecting and responding to endpoint threats' },
  @{ protocol='NDR'; purpose='detecting suspicious behavior from network telemetry' }
)

$protocolPool = @($protocolPurpose | ForEach-Object { $_.protocol })
foreach ($item in $protocolPurpose) {
  $wrong = @($protocolPool | Where-Object { $_ -ne $item.protocol } | Get-Random -Count 3)
  $opts = Shuffle (@($item.protocol) + $wrong)
  Add-McqQuestion -QuestionText "Which of the following is primarily used for $($item.purpose)?" -Options $opts -Correct $item.protocol -Explanation "$($item.protocol) is primarily associated with $($item.purpose)."
}

$securityUseCases = @(
  @{ control='Firewall'; use='filtering inbound and outbound network traffic by policy' },
  @{ control='Stateful Firewall'; use='tracking connection state while enforcing rules' },
  @{ control='NGFW'; use='application-aware filtering with threat prevention features' },
  @{ control='WAF'; use='protecting web applications from attacks like SQLi and XSS' },
  @{ control='IDS'; use='detecting suspicious activity and generating alerts' },
  @{ control='IPS'; use='blocking detected malicious traffic inline' },
  @{ control='Proxy Server'; use='intermediating client requests for policy and caching' },
  @{ control='Reverse Proxy'; use='shielding backend servers and balancing inbound traffic' },
  @{ control='VPN Gateway'; use='providing secure remote access over untrusted networks' },
  @{ control='Bastion Host'; use='hardened jump server for administrative access' },
  @{ control='Zero Trust'; use='continuous verification before granting resource access' },
  @{ control='MFA'; use='requiring more than one independent authentication factor' },
  @{ control='Biometric Authentication'; use='verifying users using inherence factors' },
  @{ control='PAM'; use='managing and monitoring privileged account sessions' },
  @{ control='Least Privilege'; use='granting minimum necessary access rights' },
  @{ control='Segregation of Duties'; use='preventing single-user control over critical process steps' },
  @{ control='Role-Based Access Control'; use='assigning permissions based on job roles' },
  @{ control='Network Segmentation'; use='limiting lateral movement across internal networks' },
  @{ control='Micro-Segmentation'; use='granular east-west traffic control in data centers' },
  @{ control='DLP'; use='preventing unauthorized sensitive data exfiltration' },
  @{ control='Tokenization'; use='replacing sensitive values with non-sensitive tokens' },
  @{ control='Data Masking'; use='obscuring sensitive fields in non-production environments' },
  @{ control='Hashing'; use='one-way integrity verification of data' },
  @{ control='Salting'; use='defending password hashes against rainbow-table attacks' },
  @{ control='Digital Signature'; use='ensuring authenticity and non-repudiation' },
  @{ control='AES-256'; use='symmetric encryption for strong data confidentiality' },
  @{ control='RSA'; use='asymmetric key exchange and digital signature support' },
  @{ control='ECDSA'; use='elliptic-curve digital signature generation and verification' },
  @{ control='HSM'; use='securely storing and processing cryptographic keys' },
  @{ control='Key Rotation'; use='reducing cryptographic risk by periodic key replacement' },
  @{ control='Patch Management'; use='closing known vulnerabilities by timely updates' },
  @{ control='Vulnerability Scanning'; use='identifying known weaknesses in systems' },
  @{ control='Penetration Testing'; use='simulating attacks to validate security posture' },
  @{ control='Red Teaming'; use='adversary emulation to test detection and response' },
  @{ control='Blue Teaming'; use='defending, monitoring, and responding to threats' },
  @{ control='SOC'; use='continuous monitoring and triage of security events' },
  @{ control='SIEM'; use='centralized log correlation and alerting' },
  @{ control='SOAR'; use='automating incident response playbooks' },
  @{ control='Threat Intelligence'; use='using IOC/TTP feeds for proactive defense' },
  @{ control='EDR'; use='detecting suspicious endpoint behavior and containment' },
  @{ control='NDR'; use='finding anomalies in network traffic patterns' },
  @{ control='UEBA'; use='baselining user/entity behavior to flag anomalies' },
  @{ control='Backup'; use='restoring data after corruption or ransomware events' },
  @{ control='Immutable Backup'; use='preventing alteration/deletion of backup copies' },
  @{ control='Disaster Recovery Plan'; use='restoring critical services after major disruption' },
  @{ control='Business Continuity Plan'; use='maintaining operations during disruptions' },
  @{ control='RTO'; use='defining maximum acceptable service restoration time' },
  @{ control='RPO'; use='defining maximum acceptable data loss window' },
  @{ control='Phishing Simulation'; use='testing and improving user awareness against social engineering' },
  @{ control='Email SPF'; use='validating authorized sending servers for a domain' },
  @{ control='Email DKIM'; use='verifying email message integrity using signatures' },
  @{ control='Email DMARC'; use='domain policy enforcement using SPF/DKIM results' },
  @{ control='Anti-Malware'; use='detecting and removing known malicious software' },
  @{ control='Sandboxing'; use='executing suspicious files in isolated environment' },
  @{ control='SASE'; use='integrating networking and security for distributed users' },
  @{ control='ZTNA'; use='application-level secure remote access without broad network trust' },
  @{ control='PCI DSS Compliance'; use='securing cardholder data handling environments' }
)

$controlPool = @($securityUseCases | ForEach-Object { $_.control })
foreach ($item in $securityUseCases) {
  $wrong = @($controlPool | Where-Object { $_ -ne $item.control } | Get-Random -Count 3)
  $opts = Shuffle (@($item.control) + $wrong)
  Add-McqQuestion -QuestionText "In Bank/Regulatory SO IT context, which control is best associated with: $($item.use)?" -Options $opts -Correct $item.control -Explanation "$($item.control) is directly used for $($item.use)."
}

if ($questions.Count -ne 250) {
  throw "Expected 250 questions, but generated $($questions.Count)."
}

$targetFile = "data/topics/computer_networks_cyber_security.json"
[ordered]@{ questions = $questions } | ConvertTo-Json -Depth 8 | Set-Content -Path $targetFile -Encoding utf8

Write-Output "Generated $($questions.Count) questions in $targetFile"


