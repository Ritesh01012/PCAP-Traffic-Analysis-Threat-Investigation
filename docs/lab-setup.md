# Lab Setup Guide

This guide covers the complete setup for the PCAP Traffic Analysis & Threat Investigation project.

## Prerequisites

- **VirtualBox** or **VMware** installed
- **Kali Linux** VM (scanner/analyst workstation)
- **Target VM**: Ubuntu Server or Metasploitable2
- **Wireshark** (current stable version) with tshark
- **Nmap** installed on Kali
- **Git** for repository management

## VM Network Configuration

### Step 1: Create Host-Only Network

**VirtualBox**:
1. File > Host Network Manager
2. Create new network (e.g., `VirtualBox Host-Only Ethernet Adapter`)
3. Configure:
   - IPv4: `192.168.56.1`
   - Network Mask: `255.255.255.0`
   - DHCP Server: Disable (for static IPs)

**VMware**:
1. Edit > Virtual Network Editor
2. Add Host-Only network (VMnet1)
3. Configure:
   - Subnet: `192.168.56.0`
   - Mask: `255.255.255.0`
   - Disable DHCP

### Step 2: Configure Kali Linux (Scanner)

1. Start Kali VM
2. Network adapter: Host-Only
3. Assign static IP:
```bash
sudo ip addr add 192.168.56.10/24 dev eth0
sudo ip link set eth0 up
```

4. Verify:
```bash
ip a
ping 192.168.56.20
```

### Step 3: Configure Target VM

**Ubuntu Server**:
```bash
sudo ip addr add 192.168.56.20/24 dev eth0
sudo ip link set eth0 up
```

**Metasploitable2**:
- Already configured with DHCP
- Check assigned IP with `ip a`
- Note the actual IP and adjust commands accordingly

### Step 4: Test Connectivity

From Kali:
```bash
ping -c 3 192.168.56.20
nmap -sn 192.168.56.20
```

## Wireshark Setup

### Step 1: Install Wireshark

**Kali Linux** (pre-installed):
```bash
sudo apt update
sudo apt install wireshark tshark
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install wireshark
```

Add user to wireshark group:
```bash
sudo usermod -aG wireshark $USER
# Log out and back in
```

### Step 2: Configure Time Display

1. Open Wireshark
2. View > Time Display Format
3. Select: **UTC Date and Time of Day**
4. All timestamps in reports will now be UTC

### Step 3: Create SOC Profile

1. Edit > Configuration Profiles > New
2. Name: `SOC`
3. Set as default

### Step 4: Add Custom Columns

1. Right-click column header > Column Preferences
2. Add the following columns:

| Column Title | Field | Type |
|--------------|-------|------|
| TCP Stream | tcp.stream | Number |
| HTTP Host | http.host | String |
| TLS SNI | tls.handshake.extensions_server_name | String |
| DNS Query | dns.qry.name | String |
| Delta Time | frame.time_delta_displayed | Time |

3. Arrange columns in preferred order
4. Apply

### Step 5: Add Color Filters (Optional)

Edit > Coloring Rules > New:

| Name | Filter | Background |
|------|--------|-------------|
| Malware Executable | frame contains "This program cannot be run in DOS mode" | Light red |
| DNS Tunneling | dns.qry.name.len > 50 | Light yellow |
| Port Scan | tcp.flags.syn == 1 && tcp.flags.ack == 0 | Light blue |
| Beaconing | tcp.stream | Light green |

### Step 6: Disable Name Resolution

**Critical for safe analysis** - prevents DNS leaks to external servers:

1. View > Name Resolution
2. Uncheck all options:
   - Resolve Network (MAC) Addresses
   - Resolve Transport Names
   - Resolve Network Layer Names

## Nmap Installation and Verification

**Kali Linux** (pre-installed):
```bash
nmap --version
```

**Other Linux**:
```bash
sudo apt install nmap
```

Verify installation:
```bash
nmap -V
```

## Directory Structure Setup

Clone or create the repository:
```bash
cd ~/Desktop
mkdir pcap-threat-investigation
cd pcap-threat-investigation
mkdir -p docs captures reports scripts screenshots iocs
```

Initialize git:
```bash
git init
git add .
git commit -m "Initial project structure"
```

## Capture Interface Identification

Find the correct interface for capturing lab traffic:

```bash
ip a
```

Look for the host-only interface (e.g., `eth1`, `enp0s8`).

Start capture with Wireshark:
1. Open Wireshark
2. Select the host-only interface
3. Start capture before generating traffic

Or use tcpdump:
```bash
sudo tcpdump -i eth1 -w capture.pcap host 192.168.56.20
```

## Safety Precautions

### VM Isolation

- Use **NAT** or **Host-Only** networking only
- **Never** use Bridged networking for malware analysis
- Take VM snapshots before opening suspicious PCAPs

### Malware Handling Rules

1. Open PCAPs inside a VM with a snapshot
2. Never run, double-click, or open exported files
3. Hash exported files and stop there sha256sum
4. Look up hashes on VirusTotal (hash submissions only)
5. Do not visit IOC domains or IPs in a browser
6. Defang all IOCs in write-ups

### Defanging Examples

- IP: `203.0.113.50` → `203[.]0[.]113[.]50`
- Domain: `bad-domain.example` → `bad-domain[.]example`
- URL: `http://bad-domain.example/payload.exe` → `hxxp://bad-domain[.]example/payload[.]exe`

## Verification Checklist

Before starting analysis:

- [ ] VMs on host-only network only
- [ ] Static IPs configured (Kali: 192.168.56.10, Target: 192.168.56.20)
- [ ] Wireshark time display set to UTC
- [ ] SOC profile created with custom columns
- [ ] Name resolution disabled in Wireshark
- [ ] Nmap installed and verified
- [ ] Directory structure created
- [ ] Git repository initialized
- [ ] VM snapshots taken

## Troubleshooting

### No Connectivity Between VMs

- Check both VMs are on same network adapter
- Verify IP addresses with `ip a`
- Check firewall: `sudo ufw status` (disable if needed: `sudo ufw disable`)
- Try pinging in both directions

### Wireshark Shows No Packets

- Verify correct interface selected
- Check interface is not in promiscuous mode issue
- Try with tcpdump first: `sudo tcpdump -i eth1`

### Permission Denied on Wireshark

```bash
sudo dpkg-reconfigure wireshark-common
# Select "Yes"
sudo usermod -aG wireshark $USER
# Log out and back in
```

### Nmap Slow or Hanging

- Check target is reachable: `ping 192.168.56.20`
- Try with fewer ports: `nmap -p 1-100 192.168.56.20`
- Check firewall on target

## Next Steps

After lab setup:
1. Capture Nmap scans (see [nmap-scan-signatures.md](nmap-scan-signatures.md))
2. Generate lab traffic (see [generate-lab-traffic.sh](../scripts/generate-lab-traffic.sh))
3. Practice Wireshark filters (see [filter-cheatsheet.md](filter-cheatsheet.md))
4. Analyze training PCAPs from Malware-Traffic-Analysis.net
5. Write incident reports using [template.md](../reports/template.md)
