# Incident Report: DNS Abuse and Beaconing

Case ID: PCAP-2026-002
Analyst: Ritesh Kumar
Date: 2026-11-22 (UTC)
Source PCAP: [To be added - TryHackMe/CyberDefenders or lab simulation], SHA-256 [To be added]

## 1. Executive Summary

This report analyzes DNS traffic exhibiting tunneling and beaconing characteristics. The capture shows a host generating DNS queries with unusually long subdomain labels, TXT record queries, and high query volume to a single parent domain. The pattern is consistent with DNS-based data exfiltration or command-and-control communication. This analysis is based on [training capture or lab simulation] for educational purposes.

## 2. Scope and Data

- **Capture Time Range**: [To be added from PCAP]
- **Duration**: [To be added]
- **Packet Count**: [To be added]
- **Tools Used**: Wireshark, tshark
- **Victim Host(s)**: [To be added - internal IP]
- **Limitations**: Network-only view, single capture window, DNS payload encoded (requires decoding)

## 3. Timeline (UTC)

| Time | Frame/Stream | Event | Evidence |
|------|--------------|-------|----------|
| [timestamp] | DNS query | First long subdomain query (>50 chars) | Filter: dns.qry.name.len > 50 |
| [timestamp] | DNS query | TXT record query to suspicious domain | Filter: dns.qry.type == 16 |
| [timestamp] | DNS query | High volume of unique subdomains | Statistics > DNS analysis |
| [timestamp] | Periodic | Regular DNS query intervals (~30s) | Filter: dns.flags.response == 0 |
| [timestamp] | DNS response | Large answer sizes (data exfiltration) | Filter: dns.flags.response == 1 |

## 4. Indicators of Compromise (Defanged)

| Type | Value | Context |
|------|-------|---------|
| Domain | [defanged parent domain] | DNS tunneling/C2 domain |
| Subdomain pattern | [pattern description] | Long, random-looking labels |
| Query Type | TXT (16), NULL (10) | Data exfiltration channels |
| Query volume | [count] queries from single host | Abnormal DNS activity |
| Subdomain length | >50 characters | Tunneling indicator |

## 5. Packet Evidence

### Evidence 1: Long DNS Names
**Filter**: `dns.qry.name.len > 50`

The capture shows multiple DNS queries with subdomain labels exceeding 50 characters. The labels appear random and use base32-like encoding. This is a classic DNS tunneling indicator, as legitimate domains rarely have such long subdomains.

**Screenshot reference**: screenshots/dns-long-names.png

### Evidence 2: TXT Record Queries
**Filter**: `dns.qry.type == 16`

The host makes frequent TXT record queries to the suspicious domain. TXT queries are uncommon in normal browsing and are often used to carry data in DNS tunneling scenarios. The query volume is significantly higher than baseline.

**Screenshot reference**: screenshots/dns-txt-queries.png

### Evidence 3: High Query Volume
**Filter**: `dns.flags.response == 0 && ip.src == <victim_ip>`

Statistics > DNS analysis shows hundreds of unique subdomains under a single parent domain, all queried from one internal host within a short time window. This concentration of DNS activity to one domain is abnormal.

**Screenshot reference**: screenshots/dns-volume.png

### Evidence 4: Regular Intervals (Beaconing)
**Filter**: `dns.flags.response == 0 && dns.qry.name contains "[domain]"`

Adding the Delta Time column reveals DNS queries occurring at regular intervals (approximately 30 seconds with small jitter). This timing pattern suggests automated beaconing rather than user-driven browsing.

**Screenshot reference**: screenshots/dns-beaconing.png

## 6. Analysis

The DNS traffic exhibits multiple indicators of tunneling: long subdomain labels, TXT queries, high query volume to a single domain, and regular timing intervals. Legitimate causes were considered (CDNs, security products) but ruled out due to the randomness of subdomains and unusual query types. The pattern is consistent with malware using DNS for C2 communication or data exfiltration. Without endpoint data, the exact purpose (C2 vs exfiltration) cannot be determined, but the network-level indicators are strong.

## 7. Confidence

**Level**: Medium

**Reasoning**: Strong pattern matching DNS tunneling indicators (long names, TXT queries, high volume). Confidence is not High because DNS tunneling has legitimate use cases (security products, CDNs) and without decoding the DNS payload or endpoint context, the exact purpose cannot be confirmed. Also, this may be a lab simulation rather than real malicious traffic.

## 8. MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|--------|-----------|-----|----------|
| Command and Control | DNS Tunneling | T1071.004 | Long subdomains, TXT queries |
| Command and Control | Application Layer Protocol: DNS | T1071.004 | High DNS volume to single domain |
| Command and Control | Application Layer Protocol | T1071.001 | Periodic query intervals |
| Exfiltration | Exfiltration Over DNS | T1048.001 | Large DNS responses, TXT queries |

## 9. Recommendations

### Immediate (Contain)
- Block the suspicious domain at DNS resolver
- Isolate the affected host from the network
- Disable any suspicious processes on the endpoint

### Short-term (Eradicate/Recover)
- Collect endpoint telemetry (processes making DNS queries)
- Decode DNS payload to identify exfiltrated data or C2 commands
- Search logs for other hosts contacting the same domain
- Flush DNS cache on affected systems

### Long-term (Prevent/Detect)
- Implement DNS monitoring and alerting for long subdomains
- Add SIEM rule for high DNS query volume to single domain
- Monitor for unusual DNS query types (TXT, NULL)
- Use DNS filtering services to block known malicious domains
- Enable DNS logging for anomaly detection

## 10. Open Questions and Limitations

- What data is being tunneled (C2 commands or exfiltrated data)?
- What is the encoding scheme used in the subdomain labels?
- Is this part of a larger campaign affecting other hosts?
- What is the initial infection vector?
- Limitation: DNS payload encoded, requires offline decoding
- Limitation: Network-only view, no endpoint process correlation
- Limitation: May be legitimate security product traffic (false positive)

---

**Status**: Template ready - requires actual PCAP analysis from TryHackMe/CyberDefenders or lab simulation
