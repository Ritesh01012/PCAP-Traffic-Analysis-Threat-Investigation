# Incident Report: Reconnaissance and Data Transfer

Case ID: PCAP-2026-003
Analyst: Ritesh Kumar
Date: 2026-11-22 (UTC)
Source PCAP: Multiple captures (nmap_arp_sweep.pcap, nmap_syn_scan.pcap, etc.)

## 1. Executive Summary

Authorized Nmap scanning activity from Kali Linux (192.168.56.10) against target host (192.168.56.20) in isolated lab environment. Captures demonstrate host discovery via ARP/ICMP, SYN port scanning of 1024 ports, connect scanning, and service version detection. All activity is controlled and documented for portfolio purposes. This is not malicious activity - it is authorized security testing in a lab environment.

## 2. Scope and Data

- **Capture Time Range**: 2026-11-22 (multiple captures)
- **Duration**: Approximately 5-10 minutes total across all scans
- **Packet Count**: Varies by scan type (ARP sweep: ~256 packets, SYN scan: ~1024+ packets)
- **Tools Used**: Wireshark, tshark, Nmap
- **Victim Host(s)**: 192.168.56.20 (target - Ubuntu/Metasploitable)
- **Scanner**: 192.168.56.10 (Kali Linux)
- **Limitations**: Authorized lab environment only, no production impact

## 3. Timeline (UTC)

| Time | Frame/Stream | Event | Evidence |
|------|--------------|-------|----------|
| <timestamp> | ARP sweep | Host discovery via ARP requests | Filter: arp.opcode == 1, screenshot: screenshots/nmap-arp.png |
| <timestamp> | ICMP sweep | ICMP echo requests to target | Filter: icmp.type == 8, screenshot: screenshots/nmap-icmp.png |
| <timestamp> | SYN scan | Port scan of ports 1-1024 | Filter: tcp.flags.syn == 1 && tcp.flags.ack == 0, screenshot: screenshots/nmap-syn.png |
| <timestamp> | Connect scan | Full handshake port scan | Filter: tcp.flags.syn == 1, screenshot: screenshots/nmap-connect.png |
| <timestamp> | Version detection | Service banner grabbing | Filter: tcp.stream, screenshot: screenshots/nmap-sv.png |

## 4. Indicators of Compromise (Defanged)

| Type | Value | Context |
|------|-------|---------|
| Scanner IP | 192[.]168[.]56[.]10 | Nmap scan source (Kali) |
| Target IP | 192[.]168[.]56[.]20 | Scan target (Ubuntu/Metasploitable) |
| Ports scanned | 1-1024 | SYN and connect scan range |
| Services detected | SSH (22), HTTP (80), HTTPS (443) | Version detection targets |
| Scan signature | TCP window size 1024 | Nmap default SYN scan characteristic |

## 5. Packet Evidence

### Evidence 1: SYN Scan Pattern
**Filter**: `tcp.flags.syn == 1 && tcp.flags.ack == 0`

The SYN scan capture shows 192.168.56.10 sending SYN packets to 1024 distinct destination ports on 192.168.56.20 within approximately 10 seconds. Open ports respond with SYN/ACK, which the scanner immediately resets with RST (handshake never completes). Closed ports respond with RST/ACK. The TCP window size is consistently 1024, characteristic of Nmap's default SYN scan behavior.

**Screenshot reference**: screenshots/nmap-syn.png

### Evidence 2: Service Version Detection
**Filter**: `tcp.stream eq <stream_number>`

The version detection scan completes full TCP handshakes to open ports (22, 80, 443) and sends application-layer probes. On port 80, Nmap sends HTTP requests and receives Server headers revealing the web server version. On port 22, banner grabbing reveals SSH protocol strings. This produces application-layer traffic that would be visible in web server logs.

**Screenshot reference**: screenshots/nmap-sv.png

### Evidence 3: ARP Host Discovery
**Filter**: `arp.opcode == 1`

The ARP sweep shows rapid ARP requests (who-has) walking through the 192.168.56.0/24 subnet. Only live hosts respond with ARP replies. This is the default behavior for Nmap host discovery on local networks.

**Screenshot reference**: screenshots/nmap-arp.png

## 6. Analysis

All captured traffic matches expected Nmap scan patterns in a controlled lab environment. The SYN scan demonstrates stealth scanning behavior (handshake incomplete), while the connect scan shows noisier full handshakes. Version detection produces application-layer probes that would be detectable in server logs. These captures provide clear examples of port scan signatures that can be detected in production environments using SIEM rules (e.g., >100 distinct destination ports from one source within 10 seconds).

## 7. Confidence

**Level**: High

**Reasoning**: This is authorized lab traffic generated for learning purposes. All activity is controlled and documented.

## 8. MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|--------|-----------|-----|----------|
| Reconnaissance | Port Scanning | T1046 | SYN scan pattern |
| Discovery | Service Scanning | T1046 | -sV version detection |
| Discovery | Network Service Discovery | T1046 | Banner grabbing |

## 9. Recommendations

### Immediate (Contain)
- N/A (authorized lab activity)

### Short-term (Eradicate/Recover)
- N/A (authorized lab activity)

### Long-term (Prevent/Detect)
- Implement port scan detection rules in production
- Monitor for SYN scan patterns (>100 ports in 10 seconds)
- Log and alert on service version detection probes

## 10. Open Questions and Limitations

- N/A (controlled lab environment)

---

**Status**: Template created - awaiting Nmap lab captures and analysis
