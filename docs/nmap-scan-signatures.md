# Nmap Scan Signatures in Wireshark

This document explains how to identify and analyze different Nmap scan types in packet captures.

## Lab Configuration

- **Scanner**: Kali Linux at 192.168.56.10
- **Target**: Ubuntu/Metasploitable at 192.168.56.20
- **Network**: Host-only 192.168.56.0/24

## Host Discovery Scans

### Ping Sweep (ARP on Local Network)

**Command**:
```bash
sudo nmap -sn 192.168.56.0/24
```

**Wireshark Signature**:
- Filter: `arp.opcode == 1`
- Pattern: Rapid ARP requests (who-has) walking through addresses
- Responses: ARP replies only from live hosts

**What to Look For**:
- One source sending ARP requests for every address in subnet
- Requests within few seconds
- Only live hosts respond with ARP replies

**Detection Idea**:
> More than 50 ARP requests from one MAC address to different IPs within 5 seconds

### ICMP Echo Request (Cross-Subnet)

**Command**:
```bash
sudo nmap -sn -PE 192.168.56.20
```

**Wireshark Signature**:
- Filter: `icmp.type == 8` (requests) or `icmp.type == 0` (replies)
- Pattern: ICMP echo requests to target
- Responses: ICMP echo replies from live hosts

**What to Look For**:
- ICMP Type 8 (echo request) packets
- From scanner to multiple targets
- ICMP Type 0 replies from live hosts

## Port Scanning

### SYN Scan (Stealth Scan)

**Command**:
```bash
sudo nmap -sS -p 1-1024 192.168.56.20
```

**Wireshark Signature**:
- Filter for probes: `ip.src == 192.168.56.10 && tcp.flags.syn == 1 && tcp.flags.ack == 0`
- Filter for closed ports: `tcp.flags.reset == 1 && tcp.flags.ack == 1`
- Filter for open ports: `tcp.flags.syn == 1 && tcp.flags.ack == 1`

**Packet Flow**:
- **Open Port**: SYN → SYN/ACK → RST (scanner resets, handshake incomplete)
- **Closed Port**: SYN → RST/ACK
- **Filtered Port**: SYN with no reply or ICMP unreachable

**Key Characteristics**:
- TCP window size often 1024 (Nmap default, but attackers can change)
- Many SYNs to different ports from one source
- SYN/ACK responses followed by RST from scanner
- Handshake never completes

**Detection Idea**:
> More than 100 distinct destination ports from one source within 10 seconds with SYN-only packets

### Connect Scan (Full Handshake)

**Command**:
```bash
nmap -sT -p 1-1024 192.168.56.20
```

**Wireshark Signature**:
- Filter: `ip.src == 192.168.56.10 && tcp.flags.syn == 1 && tcp.flags.ack == 0`
- Pattern: Full three-way handshake completed, then torn down

**Packet Flow**:
- **Open Port**: SYN → SYN/ACK → ACK → (data exchange) → FIN/ACK
- **Closed Port**: SYN → RST/ACK

**Key Characteristics**:
- Completes full three-way handshake
- More visible in application logs
- Noisier than SYN scan

**Detection Idea**:
> Many completed TCP handshakes to different ports from one source within short time window

### UDP Scan

**Command**:
```bash
sudo nmap -sU -p 1-1024 192.168.56.20
```

**Wireshark Signature**:
- Filter: `udp`
- Pattern: UDP packets to various ports
- Responses: UDP replies from open ports, ICMP port unreachable from closed

**Key Characteristics**:
- Slower than TCP scans
- ICMP Type 3 Code 3 (port unreachable) for closed ports
- No response often means open/filtered

## Service and Version Detection

### Version Detection (-sV)

**Command**:
```bash
sudo nmap -sV -p 22,80 192.168.56.20
```

**Wireshark Signature**:
- Filter: `tcp.stream eq <stream_number>`
- Pattern: Full connections with application-layer probes

**What to Look For**:
- Complete TCP handshakes (unlike SYN scan)
- Probes sent to open ports
- Banner grabbing (e.g., HTTP requests, SSH protocol strings)

**HTTP Example**:
- Follow TCP stream on port 80
- See Nmap's HTTP requests
- Server header in response (e.g., `Server: Apache/2.4.41`)

**Detection Value**:
- Produces application-layer payloads
- Web logs on target show odd requests
- SIEM can detect these probe patterns

## Timing and Stealth

### Timing Templates

**Slow Scan (-T2)**:
```bash
sudo nmap -sS -T2 -p 1-1024 192.168.56.20
```
- Packets spread over longer period
- Can slip under naive threshold rules
- Lower packets-per-second in I/O Graph

**Fast Scan (-T4)**:
```bash
sudo nmap -sS -T4 -p 1-1024 192.168.56.20
```
- Rapid packet bursts
- Higher packets-per-second
- More likely to trigger alerts

**Comparison**:
- Use I/O Graph with filter: `ip.src == 192.168.56.10 && tcp.flags.syn == 1 && tcp.flags.ack == 0`
- Compare packets-per-second between -T2 and -T4
- Note: Slower scans are harder to detect with simple thresholds

### Decoy Scan

**Command**:
```bash
sudo nmap -sS -D 192.168.56.15,192.168.56.16,ME -p 1-1024 192.168.56.20
```

**Wireshark Signature**:
- Multiple source IPs sending SYN packets
- One is real scanner (ME), others are decoys
- Pattern: Same scan pattern from multiple sources

**Detection Challenge**:
- Harder to identify true scanner
- Requires correlation with other data
- Decoy IPs may not respond to SYN/ACK (no RST)

### Fragmentation Scan

**Command**:
```bash
sudo nmap -sS -f -p 1-1024 192.168.56.20
```

**Wireshark Signature**:
- Filter: `ip.flags.mf == 1` (more fragments)
- Small fragmented packets
- Harder for firewalls/IDS to inspect

## Capture Commands

### Using tcpdump

```bash
# Start capture before scan
sudo tcpdump -i eth1 -w nmap_syn_scan.pcap host 192.168.56.20

# Run scan in another terminal
sudo nmap -sS -p 1-1024 192.168.56.20

# Stop tcpdump with Ctrl+C
```

### Using Wireshark

1. Open Wireshark
2. Select host-only interface (e.g., eth1)
3. Start capture
4. Run Nmap command
5. Stop capture
6. File > Save As > nmap_syn_scan.pcap

## Analysis Workflow

### Step 1: Identify Scan Type

1. Open capture in Wireshark
2. Statistics > Protocol Hierarchy
3. Check for ARP, ICMP, TCP, UDP dominance
4. Apply filters to identify pattern

### Step 2: Isolate Scanner Traffic

```wireshark
ip.src == 192.168.56.10
```

### Step 3: Analyze Port Scan Pattern

1. Filter: `tcp.flags.syn == 1 && tcp.flags.ack == 0`
2. Statistics > Conversations > TCP tab
3. Sort by destination ports
4. Count distinct ports

### Step 4: Check for Open Ports

```wireshark
tcp.flags.syn == 1 && tcp.flags.ack == 1
```

### Step 5: Examine Service Probes (if -sV used)

1. Follow TCP stream on open ports
2. Look for banner grabs
3. Note application-layer requests

## Detection Rules

### Rule 1: Vertical Port Scan
> More than 50 distinct destination ports from one source IP to one destination IP within 30 seconds

### Rule 2: Horizontal Port Scan
> Connections from one source IP to same destination port on more than 20 different destination IPs within 60 seconds

### Rule 3: SYN Scan Signature
> SYN packets with no ACK from one source, followed by RST responses from destination, with TCP window size 1024

### Rule 4: ARP Sweep
> More than 50 ARP requests from one MAC address within 5 seconds

### Rule 5: ICMP Sweep
> More than 30 ICMP echo requests from one source to different destinations within 10 seconds

## Screenshot Checklist

For each scan type, capture:

1. **Command line**: Terminal showing the exact nmap command
2. **Wireshark filter**: Applied filter showing scan packets
3. **Conversations tab**: Sorted by destination ports
4. **I/O Graph**: Packets-per-second for timing comparison
5. **TCP Stream**: For version detection, showing banner grab
6. **Packet details**: SYN packet with TCP window size highlighted

## Common Mistakes

- Not starting capture before scan (misses initial packets)
- Capturing on wrong interface (e.g., NAT instead of host-only)
- Forgetting to stop capture (includes unrelated traffic)
- Not using host-only network (scans leak to production)
- Analyzing with name resolution on (creates DNS noise)

## Advanced Analysis

### Correlating with Logs

- Check `/var/log/auth.log` on target for SSH connection attempts
- Check web server logs for HTTP probes from -sV scans
- Check firewall logs for blocked connections

### Baseline Comparison

- Capture normal traffic first
- Compare scan traffic against baseline
- Identify anomalies in packet timing and patterns

### Automated Detection

```bash
# Count SYN packets per source
tshark -r capture.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0" -T fields -e ip.src | sort | uniq -c | sort -rn

# Count distinct destination ports per source
tshark -r capture.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0" -T fields -e ip.src -e tcp.dstport | awk '{print $1}' | sort -u | wc -l
```

## References

- [Nmap Documentation](https://nmap.org/book/man.html)
- [Wireshark Display Filters](https://wiki.wireshark.org/DisplayFilters)
- [TCP/IP Handbook](https://www.tcpipguide.com/)
