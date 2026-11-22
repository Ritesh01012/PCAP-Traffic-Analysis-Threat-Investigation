# Incident Report: <short title>

Case ID: <ID>  
Analyst: <name>  
Date: <UTC>  
Source PCAP: <name + SHA-256>

## 1. Executive Summary

<3-5 sentences, no jargon. What happened, which host, how confident, what to do next.>

## 2. Scope and Data

- **Capture Time Range**: <start to end UTC>
- **Duration**: <X minutes/hours>
- **Packet Count**: <number>
- **Tools Used**: Wireshark, tshark, Nmap (as applicable)
- **Victim Host(s)**: <internal IP(s)>
- **Limitations**: <network-only, encrypted payload, single capture window, etc.>

## 3. Timeline (UTC)

| Time | Frame/Stream | Event | Evidence |
|------|--------------|-------|----------|
| <timestamp> | <frame/stream> | <event description> | <filter used, screenshot ref> |
| <timestamp> | <frame/stream> | <event description> | <filter used, screenshot ref> |

## 4. Indicators of Compromise (Defanged)

| Type | Value | Context |
|------|-------|---------|
| IP | <defanged IP> | <role: download host, C2, etc.> |
| Domain | <defanged domain> | <role: C2, payload delivery, etc.> |
| URL | <defanged URL> | <downloaded file> |
| File | <filename, size> | <SHA-256 hash> |
| User-Agent | <string> | <suspicious client> |
| Certificate | <issuer, validity> | <self-signed, odd CN> |

## 5. Packet Evidence

For every claim, include:
- **Filter used**: <Wireshark display filter>
- **Frame numbers**: <range>
- **Timestamp**: <UTC>
- **Screenshot reference**: <screenshots/filename.png>

### Evidence 1: <title>
<Description with filter and frame numbers>

### Evidence 2: <title>
<Description with filter and frame numbers>

## 6. Analysis

<What the evidence shows, alternative explanations considered, false positives ruled out.>

## 7. Confidence

**Level**: Low / Medium / High

<One paragraph explaining why. State what would raise or lower confidence.>

**Confidence Guide**:
- **High**: Multiple independent pieces of evidence agree (e.g., payload download + matching IOC reputation + periodic callbacks)
- **Medium**: Strong pattern but missing one confirming piece (e.g., encrypted traffic with no endpoint data)
- **Low**: Single indicator with plausible benign explanation

## 8. MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|--------|-----------|-----|----------|
| <tactic> | <technique name> | <T####> | <reference to timeline/evidence> |
| <tactic> | <technique name> | <T####> | <reference to timeline/evidence> |

## 9. Recommendations

### Immediate (Contain)
- <action>
- <action>

### Short-term (Eradicate/Recover)
- <action>
- <action>

### Long-term (Prevent/Detect)
- <action>
- <action>

## 10. Open Questions and Limitations

- <question 1>
- <question 2>
- <additional limitations not covered in Section 2>

---

**Analyst Notes**: <any additional context, assumptions, or notes for future reference>
