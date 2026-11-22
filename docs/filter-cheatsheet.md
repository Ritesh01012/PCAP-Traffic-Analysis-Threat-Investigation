# Wireshark Display Filter Cheatsheet

Essential filters for PCAP analysis and threat investigation.

## General Filters

### Host-Based Filtering
```wireshark
ip.addr == 10.20.30.45              # All traffic to/from one host
ip.src == 10.20.30.45               # Only from this host
ip.dst == 10.20.30.45               # Only to this host
```

### Conversation Isolation
```wireshark
tcp.stream eq 12                    # Isolate one TCP conversation
# Right-click packet > Conversation Filter > TCP does the same
```

### Time-Based Filtering
```wireshark
frame.time >= "2026-10-05 09:00:00" && frame.time <= "2026-10-05 09:10:00"
```

### Noise Reduction
```wireshark
!(arp || icmp || dns || ssdp || mdns)    # Strip background noise
```

## DNS Filters

### All DNS Traffic
```wireshark
dns
```

### Queries Only
```wireshark
dns.flags.response == 0
```

### Responses Only
```wireshark
dns.flags.response == 1
```

### NXDOMAIN Responses (Failed Lookups)
```wireshark
dns.flags.rcode == 3
```

### Domain/Keyword Matching
```wireshark
dns.qry.name contains "example"
```

### Long Names (DNS Tunneling Indicator)
```wireshark
dns.qry.name.len > 50
```

### TXT Queries (Data Exfiltration Indicator)
```wireshark
dns.qry.type == 16
```

### NULL Queries
```wireshark
dns.qry.type == 10
```

### DNS over TCP
```wireshark
dns && tcp
```

## TCP Filters

### Connection Attempts (SYN Packets)
```wireshark
tcp.flags.syn == 1 && tcp.flags.ack == 0
```

### Reset Packets (Closed Ports/Rejected Connections)
```wireshark
tcp.flags.reset == 1
```

### Expert Analysis Flags
```wireshark
tcp.analysis.flags
```

### Retransmissions
```wireshark
tcp.analysis.retransmission
```

### TCP on Unusual Ports
```wireshark
tcp && !(tcp.port in {80 443 53 22 445})
```

### Specific Suspicious Port
```wireshark
tcp.port == 4444
```

### Zero Window (Flow Control Issues)
```wireshark
tcp.analysis.zero_window
```

### Window Full
```wireshark
tcp.analysis.window_full
```

### Fast Retransmissions
```wireshark
tcp.analysis.fast_retransmission
```

## HTTP Filters

### All HTTP Requests
```wireshark
http.request
```

### POST Requests (Data Upload)
```wireshark
http.request.method == "POST"
```

### GET Requests
```wireshark
http.request.method == "GET"
```

### Error Responses (4xx, 5xx)
```wireshark
http.response.code >= 400
```

### Specific Error Code
```wireshark
http.response.code == 404
http.response.code == 500
```

### Scripted Clients
```wireshark
http.user_agent contains "curl" || http.user_agent contains "python"
```

### Specific User-Agent
```wireshark
http.user_agent contains "Mozilla"
```

### HTTP to Specific Host
```wireshark
http.host == "example.com"
```

### Executable in Payload
```wireshark
frame contains "This program cannot be run in DOS mode"
```

### Basic Authentication
```wireshark
http.authorization
```

### HTTP with Specific Content-Type
```wireshark
http.content_type contains "application"
```

## TLS/SSL Filters

### Client Hello (SNI Visible)
```wireshark
tls.handshake.type == 1
```

### Server Certificates
```wireshark
tls.handshake.type == 11
```

### TLS Alerts (Handshake Failures)
```wireshark
tls.alert_message
```

### TLS Version 1.2
```wireshark
tls.handshake.version == 0x0303
```

### TLS Version 1.3
```wireshark
tls.handshake.version == 0x0304
```

### Self-Signed Certificates (Manual Check)
```wireshark
tls.handshake.type == 11
# Then check certificate details in packet details
```

### TLS on Non-Standard Port
```wireshark
tls && !(tcp.port in {443 8443})
```

## FTP Filters

### FTP Commands
```wireshark
ftp.request.command
```

### FTP Credentials (Cleartext)
```wireshark
ftp.request.command == "USER" || ftp.request.command == "PASS"
```

### FTP Data Transfer
```wireshark
ftp-data
```

### FTP Response Codes
```wireshark
ftp.response.code
```

## ICMP Filters

### Ping Requests
```wireshark
icmp.type == 8
```

### Ping Replies
```wireshark
icmp.type == 0
```

### Destination Unreachable
```wireshark
icmp.type == 3
```

### All ICMP
```wireshark
icmp
```

## ARP Filters

### ARP Requests
```wireshark
arp.opcode == 1
```

### ARP Replies
```wireshark
arp.opcode == 2
```

### All ARP
```wireshark
arp
```

## SMB Filters

### SMB Commands
```wireshark
smb.cmd
```

### SMB2 Commands
```wireshark
smb2.cmd
```

### SMB Tree Connect
```wireshark
smb.cmd == 0x75
```

## Combined Filters

### Beaconing Detection (HTTPS)
```wireshark
ip.dst == <external_ip> && tls.handshake.type == 1
# Add Delta Time column to check intervals
```

### Scan Detection
```wireshark
tcp.flags.syn == 1 && tcp.flags.ack == 0
# Check Conversations for many destination ports
```

### Data Exfiltration (HTTP POST)
```wireshark
http.request.method == "POST" && ip.src == <victim_ip>
```

### Malware Download
```wireshark
http.response.code == 200 && frame contains "MZ"
```

### DNS Tunneling
```wireshark
dns.qry.name.len > 50 && dns.qry.type == 16
```

### Suspicious TLS
```wireshark
tls.handshake.type == 11 && x509sat.validity.notAfter < <date>
# Check for short validity certificates
```

## Filter Modifiers

### NOT
```wireshark
!dns
```

### AND
```wireshark
dns && ip.src == 10.0.0.1
```

### OR
```wireshark
tcp.port == 80 || tcp.port == 443
```

### Grouping
```wireshark
(dns || http) && ip.src == 10.0.0.1
```

## Useful Display Columns

Add these columns for faster analysis:

| Column | Field | Purpose |
|--------|-------|---------|
| Delta Time | frame.time_delta_displayed | Detect beaconing intervals |
| TCP Stream | tcp.stream | Follow conversations |
| HTTP Host | http.host | Identify web servers |
| TLS SNI | tls.handshake.extensions_server_name | See requested domain in TLS |
| DNS Query | dns.qry.name | Track DNS lookups |
| Bytes | frame.len | Identify large transfers |

## Quick Reference Card

### Scan Detection
- SYN scan: `tcp.flags.syn == 1 && tcp.flags.ack == 0`
- Port scan: Many SYN packets to different ports from one source

### Beaconing Detection
- Filter to destination: `ip.dst == <IP> && tls.handshake.type == 1`
- Add Delta Time column
- Look for consistent intervals (± jitter)

### DNS Tunneling
- Long names: `dns.qry.name.len > 50`
- TXT queries: `dns.qry.type == 16`
- High volume from one host

### Executable Transfer
- HTTP: `http.response.code == 200 && frame contains "MZ"`
- Any protocol: `frame contains "This program cannot be run in DOS mode"`

### Cleartext Credentials
- FTP: `ftp.request.command == "USER" || ftp.request.command == "PASS"`
- HTTP Basic: `http.authorization`
- Telnet: Follow TCP stream on port 23

## Tips for Effective Filtering

1. **Start broad, then narrow**: Begin with protocol filter, then add conditions
2. **Use Statistics**: Conversations and Endpoints tabs before writing filters
3. **Right-click shortcuts**: Right-click field > Apply as Filter > Selected
4. **Save filters**: Bookmark frequently used filters
5. **Combine with coloring**: Color rules + filters for visual analysis
6. **Use profiles**: Different profiles for different analysis types

## Common Filter Mistakes

- Using `=` instead of `==` for equality
- Forgetting to escape special characters in strings
- Not grouping complex conditions with parentheses
- Confusing display filters with capture filters
- Case sensitivity: most fields are case-insensitive, but check documentation
