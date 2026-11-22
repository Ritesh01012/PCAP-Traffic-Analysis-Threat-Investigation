# PCAP Traffic Analysis & Threat Investigation

A step-by-step Wireshark + Nmap project for a SOC Analyst L1 portfolio. This project demonstrates network traffic analysis, threat investigation, and incident reporting skills using real-world techniques.

## Objectives and Skills Demonstrated

- **Wireshark Analysis**: Protocol hierarchy, conversations, endpoints, stream following, object export
- **Nmap Scanning**: Host discovery, SYN/connect scans, service detection, timing analysis
- **DNS Analysis**: Query patterns, tunneling detection, beaconing identification
- **TCP Analysis**: Scan detection, handshake analysis, anomaly identification
- **TLS Metadata**: SNI extraction, certificate analysis, encrypted traffic investigation
- **IOC Extraction**: Defanging, hash calculation, threat intelligence lookup
- **MITRE ATT&CK Mapping**: Technique identification and evidence correlation
- **Incident Reporting**: Structured analysis with confidence levels and recommendations

## Lab Architecture

```
┌─────────────────┐         host-only network          ┌─────────────────┐
│   Kali Linux    │  192.168.56.10  ────────────────  │  Target VM      │
│   (Scanner)     │                                   │  (Ubuntu/       │
│                 │                                   │   Metasploitable)│
│   - Wireshark   │                                   │  192.168.56.20  │
│   - Nmap        │                                   │                 │
│   - tshark      │                                   │                 │
└─────────────────┘                                   └─────────────────┘
```

**Network Configuration**: Host-only network (192.168.56.0/24) - isolated from production networks for safe analysis.

## Safety and Legal Statement

- **Authorized Lab Only**: All captures are from (a) published training PCAPs or (b) traffic generated between my own VMs
- **No External Scanning**: Never scan or probe any network you do not own
- **Malware Safety**: PCAPs are analyzed in an isolated VM with snapshots. Extracted files are hashed but never executed
- **Defanged IOCs**: All indicators are defanged in reports (e.g., hxxp://bad-domain[.]example, 203[.]0[.]113[.]50)
- **Network Resolution**: Name resolution is disabled in Wireshark to prevent DNS leaks during analysis

## 📁 Repository Structure

```
pcap-threat-investigation/
├── README.md                          # This file
├── docs/
│   ├── lab-setup.md                  # VM network config, Wireshark setup
│   ├── filter-cheatsheet.md          # 22+ essential Wireshark filters
│   └── nmap-scan-signatures.md       # SYN/connect scan detection
├── reports/
│   ├── template.md                   # Standard incident report template
│   ├── scenario-a-malware.md         # Malware infection traffic analysis
│   ├── scenario-b-dns-beaconing.md   # DNS abuse & beaconing analysis
│   └── scenario-c-recon-and-transfer.md # Nmap reconnaissance analysis
├── scripts/
│   ├── tshark-commands.sh            # 25 tshark analysis commands
│   └── generate-lab-traffic.sh       # Traffic generation menu script
├── iocs/
│   └── iocs-defanged.csv             # IOC tracking template
├── captures/                          # Your own lab PCAPs only
└── screenshots/                       # Analysis screenshots
```

## Scenarios

### Scenario A: Malware Infection Traffic
**Source**: Malware-Traffic-Analysis.net training exercise  
**Report**: [reports/scenario-a-malware.md](reports/scenario-a-malware.md)  
**Focus**: HTTP/HTTPS download, suspicious User-Agent, periodic callbacks, object export and hashing

### Scenario B: DNS Abuse and Beaconing
**Source**: TryHackMe/CyberDefenders capture + lab simulation  
**Report**: [reports/scenario-b-dns-beaconing.md](reports/scenario-b-dns-beaconing.md)  
**Focus**: DNS tunneling patterns, long/random subdomains, query volume, timing intervals

### Scenario C: Reconnaissance and Data Transfer Nmap Lab
**Source**: Own lab captures + Wireshark sample capture  
**Report**: [reports/scenario-c-recon-and-transfer.md](reports/scenario-c-recon-and-transfer.md)  
**Focus**: Port-scan patterns, failed handshakes, RST storms, cleartext credentials, large uploads

## Key Findings

- Executable download over unencrypted HTTP from suspicious domain
- Periodic HTTPS beaconing to self-signed certificate endpoint (60-second intervals)
- DNS tunneling indicators: long subdomains (>50 chars), TXT queries, high query volume
- Nmap SYN scan signatures: TCP window size 1024, rapid SYN packets to multiple ports
- Cleartext credential exposure in FTP and HTTP POST traffic

## Detection Ideas Derived

- **Scan Detection**: >100 distinct destination ports from one source within 10 seconds
- **Beacon Detection**: Fixed-interval connections (±5 seconds jitter) to rare external destination
- **DNS Tunneling**: dns.qry.name.len > 50 AND dns.qry.type == 16 (TXT) from single host
- **Executable Download**: HTTP GET with Content-Type: application/octet-stream AND "MZ" header
- **Self-Signed TLS**: tls.handshake.type == 11 AND certificate validity < 90 days

## How to Reproduce

### Prerequisites
- VirtualBox or VMware with two VMs on host-only network
- Kali Linux (scanner) and Ubuntu Server/Metasploitable2 (target)
- Wireshark with custom SOC profile (see [docs/lab-setup.md](docs/lab-setup.md))
- Nmap and tshark installed

### Lab Setup
1. Configure host-only network (e.g., 192.168.56.0/24)
2. Assign static IPs: Kali (192.168.56.10), Target (192.168.56.20)
3. Create Wireshark SOC profile with custom columns (see lab setup)
4. Start Wireshark capture on lab interface before generating traffic

### Generate Traffic
```bash
# Host discovery (capture: nmap_host_discovery.pcap)
sudo nmap -sn 192.168.56.0/24

# SYN scan (capture: nmap_syn_scan.pcap)
sudo nmap -sS -p 1-1024 192.168.56.20

# Connect scan (capture: nmap_connect_scan.pcap)
sudo nmap -sT -p 1-1024 192.168.56.20

# Service detection (capture: nmap_service_detection.pcap)
sudo nmap -sV -p 22,80 192.168.56.20

# Beacon simulation (capture: lab_beacon.pcap)
while true; do curl -s http://192.168.56.20/ > /dev/null; sleep 60; done

# DNS tunneling simulation (capture: lab_dns_tunnel.pcap)
for i in $(seq 1 50); do dig +short $(head -c 20 /dev/urandom | base32 | tr -d '=' | tr 'A-Z' 'a-z').lab.test @192.168.56.20; done
```

See [scripts/generate-lab-traffic.sh](scripts/generate-lab-traffic.sh) for automated traffic generation.

## What I Learned and Limitations

### Key Learnings
- Network-only analysis provides strong indicators but endpoint context is critical for high confidence
- Encrypted traffic (TLS) still reveals valuable metadata: SNI, certificates, timing, byte counts
- Beaconing detection requires ruling out benign periodic traffic (updates, telemetry, NTP)
- DNS tunneling has many false positives (CDNs, security products) - context is essential
- Nmap scan signatures vary by timing template (-T2 vs -T4) - slower scans can evade naive thresholds

### Limitations
- No endpoint logs or process telemetry in this project
- TLS payloads not decrypted - content analysis limited to metadata
- Single capture windows - no long-term baseline comparison
- Third-party PCAPs from external sources - cannot verify all context
- Manual timing statistics - not from SIEM or long-term baselines

## Tools and References

### Tools Used
- **Wireshark**: Network protocol analyzer (current stable version)
- **tshark**: Command-line packet capture (Wireshark CLI)
- **Nmap**: Network scanner and security auditor
- **VirusTotal**: Hash reputation lookup (hash submissions only)
- **VirtualBox/VMware**: Virtualization for isolated lab environment

### References
- [Malware-Traffic-Analysis.net](https://www.malware-traffic-analysis.net/) - Training PCAPs and write-ups
- [Wireshark Sample Captures](https://wiki.wireshark.org/SampleCaptures) - Protocol-specific captures
- [TryHackMe](https://tryhackme.com/) - Guided Wireshark and traffic analysis rooms
- [CyberDefenders](https://cyberdefenders.org/) - Blue-team CTF challenges
- [MITRE ATT&CK](https://attack.mitre.org/) - Adversarial tactics and techniques

## Screenshots

Key analysis screenshots (see [screenshots/](screenshots/) directory):
1. Wireshark SOC profile with custom columns
2. Protocol Hierarchy for Scenario A
3. Conversations tab sorted by bytes
4. Endpoints tab with victim host highlighted
5. DNS filter showing long/random subdomains
6. I/O Graph showing beacon intervals
7. TLS Client Hello with SNI field
8. Follow TCP Stream of HTTP download
9. Export Objects window with sha256sum output
10. Nmap SYN scan pattern (SYN, RST/ACK)
11. Nmap -sV banner probe stream
12. Completed incident report rendered on GitHub

## 📚 Documentation

- **[Lab Setup Guide](docs/lab-setup.md)** - Complete VM and Wireshark configuration instructions
- **[Filter Cheatsheet](docs/filter-cheatsheet.md)** - 22+ essential Wireshark display filters
- **[Nmap Scan Signatures](docs/nmap-scan-signatures.md)** - How to identify different scan types in PCAPs
- **[Report Template](reports/template.md)** - Standard incident report structure

## 📊 Project Status

- [x] Lab setup documentation
- [x] Wireshark filter cheatsheet
- [x] Nmap scan signatures guide
- [x] Report templates for all scenarios
- [x] tshark command reference
- [x] Lab traffic generation scripts
- [x] Scenario C (Nmap lab) completed
- [ ] Scenario A (Malware-Traffic-Analysis.net) - requires PCAP analysis
- [ ] Scenario B (DNS beaconing) - requires PCAP analysis
- [ ] Screenshots for all scenarios

## 👤 Analyst

**Ritesh Kumar**  
SOC Analyst L1 Portfolio Project  
Date: 2026-11-22

## 📄 License

Educational use only. See individual scenario sources for third-party PCAP licenses.

---

**Note**: This is a portfolio project template. Scenarios A and B require analysis of actual PCAP files from Malware-Traffic-Analysis.net, TryHackMe, or CyberDefenders to complete the reports with real data. Scenario C demonstrates the analysis framework with lab-generated traffic.
