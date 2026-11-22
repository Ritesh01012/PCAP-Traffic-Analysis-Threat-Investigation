#!/bin/bash

# tshark Commands for PCAP Analysis
# This script contains useful tshark commands for traffic analysis
# Usage: ./tshark-commands.sh <pcap_file>

if [ -z "$1" ]; then
    echo "Usage: $0 <pcap_file>"
    echo "Example: $0 capture.pcap"
    exit 1
fi

PCAP="$1"

echo "=== PCAP Analysis with tshark ==="
echo "File: $PCAP"
echo ""

# 1. Protocol Hierarchy Statistics
echo "1. Protocol Hierarchy Statistics"
echo "================================"
tshark -r "$PCAP" -q -z io,phs
echo ""

# 2. TCP Conversations
echo "2. TCP Conversations"
echo "===================="
tshark -r "$PCAP" -q -z conv,tcp
echo ""

# 3. UDP Conversations
echo "3. UDP Conversations"
echo "===================="
tshark -r "$PCAP" -q -z conv,udp
echo ""

# 4. IP Endpoints
echo "4. IP Endpoints"
echo "==============="
tshark -r "$PCAP" -q -z endpoints,ip
echo ""

# 5. TCP Endpoints
echo "5. TCP Endpoints"
echo "================"
tshark -r "$PCAP" -q -z endpoints,tcp
echo ""

# 6. DNS Queries with Timestamps
echo "6. DNS Queries"
echo "=============="
tshark -r "$PCAP" -Y "dns.flags.response==0" -T fields -e frame.time -e ip.src -e dns.qry.name -e dns.qry.type
echo ""

# 7. DNS Responses
echo "7. DNS Responses"
echo "================"
tshark -r "$PCAP" -Y "dns.flags.response==1" -T fields -e frame.time -e ip.src -e dns.qry.name -e dns.flags.rcode
echo ""

# 8. TLS Client Hello (SNI)
echo "8. TLS Client Hello (SNI)"
echo "========================="
tshark -r "$PCAP" -Y "tls.handshake.type==1" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tls.handshake.extensions_server_name
echo ""

# 9. TLS Server Certificates
echo "9. TLS Server Certificates"
echo "=========================="
tshark -r "$PCAP" -Y "tls.handshake.type==11" -T fields -e frame.time -e ip.src -e x509sat.subject.commonName -e x509sat.issuer.commonName
echo ""

# 10. HTTP Requests
echo "10. HTTP Requests"
echo "================="
tshark -r "$PCAP" -Y "http.request" -T fields -e frame.time -e ip.src -e ip.dst -e http.request.method -e http.host -e http.request.uri
echo ""

# 11. HTTP User-Agents
echo "11. HTTP User-Agents"
echo "===================="
tshark -r "$PCAP" -Y "http.user_agent" -T fields -e http.user_agent | sort | uniq -c | sort -rn
echo ""

# 12. HTTP POST Requests (Potential Data Exfiltration)
echo "12. HTTP POST Requests"
echo "======================"
tshark -r "$PCAP" -Y "http.request.method==\"POST\"" -T fields -e frame.time -e ip.src -e http.host -e http.request.uri -e http.content_length
echo ""

# 13. TCP SYN Packets (Port Scan Detection)
echo "13. TCP SYN Packets (Scan Detection)"
echo "===================================="
tshark -r "$PCAP" -Y "tcp.flags.syn==1 && tcp.flags.ack==0" -T fields -e frame.time -e ip.src -e tcp.dstport
echo ""

# 14. TCP Reset Packets
echo "14. TCP Reset Packets"
echo "======================"
tshark -r "$PCAP" -Y "tcp.flags.reset==1" -T fields -e frame.time -e ip.src -e ip.dst -e tcp.srcport
echo ""

# 15. ICMP Traffic
echo "15. ICMP Traffic"
echo "================"
tshark -r "$PCAP" -Y "icmp" -T fields -e frame.time -e ip.src -e ip.dst -e icmp.type
echo ""

# 16. ARP Traffic
echo "16. ARP Traffic"
echo "==============="
tshark -r "$PCAP" -Y "arp" -T fields -e frame.time -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode
echo ""

# 17. Top Talkers by Bytes
echo "17. Top Talkers by Bytes"
echo "========================"
tshark -r "$PCAP" -q -z io,stat,0,"ip.addr"
echo ""

# 18. Long DNS Names (>50 chars)
echo "18. Long DNS Names (>50 chars)"
echo "=============================="
tshark -r "$PCAP" -Y "dns.qry.name.len > 50" -T fields -e frame.time -e ip.src -e dns.qry.name
echo ""

# 19. TXT DNS Queries (Tunneling Indicator)
echo "19. TXT DNS Queries"
echo "==================="
tshark -r "$PCAP" -Y "dns.qry.type==16" -T fields -e frame.time -e ip.src -e dns.qry.name
echo ""

# 20. FTP Commands
echo "20. FTP Commands"
echo "================"
tshark -r "$PCAP" -Y "ftp.request.command" -T fields -e frame.time -e ip.src -e ftp.request.command -e ftp.request.arg
echo ""

# 21. Executable Files in HTTP
echo "21. Executable Files in HTTP"
echo "============================"
tshark -r "$PCAP" -Y "frame contains \"This program cannot be run in DOS mode\"" -T fields -e frame.number -e frame.time -e ip.src -e ip.dst
echo ""

# 22. TLS Alerts
echo "22. TLS Alerts"
echo "=============="
tshark -r "$PCAP" -Y "tls.alert_message" -T fields -e frame.time -e ip.src -e tls.alert_message.level -e tls.alert_message.description
echo ""

# 23. Packet Count by Protocol
echo "23. Packet Count by Protocol"
echo "============================"
tshark -r "$PCAP" -T fields -e frame.protocol | sort | uniq -c | sort -rn
echo ""

# 24. Time Range
echo "24. Capture Time Range"
echo "======================"
tshark -r "$PCAP" -T fields -e frame.time | head -1
tshark -r "$PCAP" -T fields -e frame.time | tail -1
echo ""

# 25. Total Packet Count
echo "25. Total Packet Count"
echo "======================"
tshark -r "$PCAP" -T fields -e frame.number | wc -l
echo ""

echo "=== Analysis Complete ==="
