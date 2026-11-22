#!/bin/bash

# Lab Traffic Generator for PCAP Analysis
# This script generates various types of traffic for analysis practice
# Run this on Kali Linux while capturing on the host-only interface

TARGET="192.168.56.20"
SCANNER_IP="192.168.56.10"

echo "=== Lab Traffic Generator ==="
echo "Target: $TARGET"
echo "Scanner: $SCANNER_IP"
echo ""
echo "IMPORTANT: Start Wireshark or tcpdump capture BEFORE running these commands"
echo ""

# Check if target is reachable
echo "Checking connectivity to $TARGET..."
ping -c 2 $TARGET
if [ $? -ne 0 ]; then
    echo "ERROR: Target $TARGET is not reachable. Check network configuration."
    exit 1
fi
echo "Target is reachable."
echo ""

# Menu
echo "Select traffic type to generate:"
echo "1. Host Discovery (ARP sweep)"
echo "2. Host Discovery (ICMP)"
echo "3. SYN Scan"
echo "4. Connect Scan"
echo "5. Service Version Detection"
echo "6. UDP Scan"
echo "7. Beaconing Simulation (HTTP)"
echo "8. DNS Tunneling Simulation"
echo "9. All Scans (Sequential)"
echo "10. Generate All Traffic"
echo "0. Exit"
read -p "Enter choice: " choice

case $choice in
    1)
        echo "Generating ARP sweep..."
        sudo nmap -sn 192.168.56.0/24
        ;;
    2)
        echo "Generating ICMP ping sweep..."
        sudo nmap -sn -PE 192.168.56.20
        ;;
    3)
        echo "Generating SYN scan (ports 1-1024)..."
        sudo nmap -sS -p 1-1024 $TARGET
        ;;
    4)
        echo "Generating Connect scan (ports 1-1024)..."
        sudo nmap -sT -p 1-1024 $TARGET
        ;;
    5)
        echo "Generating Service Version Detection..."
        sudo nmap -sV -p 22,80,443,21,23 $TARGET
        ;;
    6)
        echo "Generating UDP scan (top 100 ports)..."
        sudo nmap -sU --top-ports 100 $TARGET
        ;;
    7)
        echo "Generating Beaconing Simulation (HTTP every 60 seconds)"
        echo "Press Ctrl+C to stop"
        read -p "Start capture now, then press Enter to begin..."
        while true; do
            curl -s http://$TARGET/ > /dev/null
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Beacon sent"
            sleep 60
        done
        ;;
    8)
        echo "Generating DNS Tunneling Simulation (50 random subdomains)"
        read -p "Start capture now, then press Enter to begin..."
        for i in $(seq 1 50); do
            random_sub=$(head -c 20 /dev/urandom | base32 | tr -d '=' | tr 'A-Z' 'a-z')
            dig +short ${random_sub}.lab.test @$TARGET > /dev/null
            echo "[$i/50] Query: ${random_sub}.lab.test"
            sleep 0.5
        done
        echo "DNS tunneling simulation complete"
        ;;
    9)
        echo "Running all scans sequentially..."
        echo "Starting ARP sweep..."
        sudo nmap -sn 192.168.56.0/24
        sleep 2
        echo "Starting ICMP ping sweep..."
        sudo nmap -sn -PE $TARGET
        sleep 2
        echo "Starting SYN scan..."
        sudo nmap -sS -p 1-1024 $TARGET
        sleep 2
        echo "Starting Connect scan..."
        sudo nmap -sT -p 1-1024 $TARGET
        sleep 2
        echo "Starting Service Version Detection..."
        sudo nmap -sV -p 22,80,443 $TARGET
        sleep 2
        echo "All scans complete"
        ;;
    10)
        echo "Generating ALL traffic types..."
        echo "Starting ARP sweep..."
        sudo nmap -sn 192.168.56.0/24
        sleep 2
        echo "Starting ICMP ping sweep..."
        sudo nmap -sn -PE $TARGET
        sleep 2
        echo "Starting SYN scan..."
        sudo nmap -sS -p 1-1024 $TARGET
        sleep 2
        echo "Starting Connect scan..."
        sudo nmap -sT -p 1-1024 $TARGET
        sleep 2
        echo "Starting Service Version Detection..."
        sudo nmap -sV -p 22,80,443 $TARGET
        sleep 2
        echo "Starting UDP scan..."
        sudo nmap -sU --top-ports 50 $TARGET
        sleep 2
        echo "Starting DNS tunneling simulation..."
        for i in $(seq 1 30); do
            random_sub=$(head -c 20 /dev/urandom | base32 | tr -d '=' | tr 'A-Z' 'a-z')
            dig +short ${random_sub}.lab.test @$TARGET > /dev/null
            sleep 0.3
        done
        echo "Starting beaconing simulation (10 beacons, 10 second intervals for demo)..."
        for i in $(seq 1 10); do
            curl -s http://$TARGET/ > /dev/null
            echo "[$i/10] Beacon sent"
            sleep 10
        done
        echo "All traffic generation complete"
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Traffic generation complete. Stop your capture and save the PCAP file."
