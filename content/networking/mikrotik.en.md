---
title: MikroTik Router
---

{{< hint type="note" title="Introduction" >}}

[MikroTik](https://mikrotik.com/) routers provide professional solutions at
affordable prices, making them ideal for personal use. Whether for routers,
switches, or Wi-Fi access points, all devices run on
[RouterOS](https://mikrotik.com/software). Regardless of the device, each model
can serve as a router, firewall, and switch. You can start with a model like the
[hEX lite](https://mikrotik.com/product/RB750r2), available for around **€40**.

{{< /hint >}}

{{< hint type=tip title=Tip >}}

It is also possible to test RouterOS on a
[virtual machine](https://mikrotik.com/software) for 24 hours.

{{< /hint >}}

{{< toc >}}

---

## Features

MikroTik routers offer the following functionalities:

- **Network:**
  - [Bridge](https://help.mikrotik.com/docs/spaces/ROS/pages/328068/Bridging+and+Switching)
  - [VLAN](https://help.mikrotik.com/docs/spaces/ROS/pages/88014957/VLAN)
  - QoS
    ([Hardware](https://help.mikrotik.com/docs/spaces/ROS/pages/11993091/QoS+with+Switch+Chip)
    / Software)
  - DHCP Server
  - Switching
    ([STP, RSTP](https://help.mikrotik.com/docs/spaces/ROS/pages/21725254/Spanning+Tree+Protocol#SpanningTreeProtocol-STPandRSTP))
- **Routing:**
  - Static and dynamic routing
    ([OSPF](https://en.wikipedia.org/wiki/Open_Shortest_Path_First),
    [BGP](https://en.wikipedia.org/wiki/Border_Gateway_Protocol),
    [RIP](https://en.wikipedia.org/wiki/Routing_Information_Protocol),
    [MPLS](https://en.wikipedia.org/wiki/Multiprotocol_Label_Switching))
  - [Load Balancing](https://help.mikrotik.com/docs/spaces/ROS/pages/4390920/Load+Balancing)
  - [Failover](https://help.mikrotik.com/docs/spaces/ROS/pages/26476608/Failover+WAN+Backup)
- **Security:**
  - Firewall
    ([DDoS Protection](https://help.mikrotik.com/docs/spaces/ROS/pages/28606504/DDoS+Protection),
    [Port knocking](https://help.mikrotik.com/docs/spaces/ROS/pages/154042369/Port+knocking))
  - VPN
    ([IPsec](https://help.mikrotik.com/docs/spaces/ROS/pages/11993097/IPsec),
    [OpenVPN](https://help.mikrotik.com/docs/spaces/ROS/pages/2031655/OpenVPN),
    [SSTP](https://help.mikrotik.com/docs/spaces/ROS/pages/2031645/SSTP),
    [WireGuard](https://help.mikrotik.com/docs/spaces/ROS/pages/69664792/WireGuard))
- **Wi-Fi:**
  - ([AP Controller](https://help.mikrotik.com/docs/spaces/ROS/pages/1409149/AP+Controller+CAPsMAN),
    [Hotspot](https://help.mikrotik.com/docs/spaces/ROS/pages/56459266/HotSpot+-+Captive+portal))

For more information, consult the
[official documentation](https://help.mikrotik.com/docs/spaces/ROS/pages/19136707/Software+Specifications).

---

## Detailed Features

### Safe Mode

{{< hint type="important" >}}

**Safe Mode** protects against configuration errors that may result in loss of
access.

{{< /hint >}}

From the command line, press **`CTRL-x`** to activate this mode, identifiable by
the **`<SAFE>`** indicator in the prompt.

**How does it work?**

In Safe Mode, the router periodically tests the connectivity between itself and
the administrator's SSH session. If a connection loss is detected, it restores
the previous configuration.

To save your changes while staying connected, disable Safe Mode by pressing
**`CTRL-x`** again.

---

### Firewall

MikroTik routers include two types of firewalls: Layer 2 and Layer 3.

#### Layer 3 Example

```bash
/ip/firewall/filter
# Input
add action=accept chain=input comment="accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="drop invalid" connection-state=invalid
add action=accept chain=input comment="accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="drop all not coming from LAN" in-interface-list=!LAN log=yes log-prefix=BAN

# Forward
add action=fasttrack-connection chain=forward comment="fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN

# Masquerade
/ip firewall nat
add action=masquerade chain=srcnat comment="masquerade" ipsec-policy=out,none out-interface-list=WAN
```

---

### VLAN

VLANs allow isolating multiple network streams within the same bridge. For
example, you can separate traffic between the LAN and a DMZ without interaction
between them. Two key concepts:

- **Tagged (trunk):** Adds a VLAN number to the Ethernet header of the IP packet
  for compatible devices ([802.1Q](https://en.wikipedia.org/wiki/IEEE_802.1Q)).
- **Untagged:** Removes the VLAN number to make the packet accessible to
  standard devices.

#### Example

The following example configures two VLANs: **LAN (2)** and **DMZ (3)**. All
ports are dedicated to the LAN except:

- `ether10` for the DMZ.
- `ether2`, used as a trunk (tagged) to carry LAN and DMZ traffic.

```bash
# Temporarily disable VLAN filtering
/interface/bridge
set [find where name="bridge"] vlan-filtering=no

# Assign all ports to VLAN-LAN (PVID 2)
/interface/bridge/port
set [find] pvid=2

# Assign ether10 to VLAN-DMZ (PVID 3)
set [find where interface=ether10] pvid=3

# Configure the trunk (ether2)
/interface/bridge/vlan
add bridge=bridge comment=eth2-lan tagged=ether2,bridge vlan-ids=2
add bridge=bridge comment=eth2-dmz tagged=ether2,bridge vlan-ids=3

# Create VLAN interfaces
/interface/vlan
add interface=bridge name=vlan-lan vlan-id=2
add interface=bridge name=vlan-dmz vlan-id=3

# IP addressing
/ip/address
add address=192.168.2.254/24 interface=vlan-lan
add address=192.168.3.254/24 interface=vlan-dmz

# Configure DHCP pools
/ip/pool
add name=dhcp-lan ranges=192.168.2.128/25
add name=dhcp-dmz ranges=192.168.3.128/25

# Add DHCP servers
/ip/dhcp-server
add address-pool=dhcp-lan interface=vlan-lan
add address-pool=dhcp-dmz interface=vlan-dmz
```

#### Applying the Configuration

To preserve the entire configuration (while still in `<SAFE>` mode), exit Safe
Mode by pressing **`CTRL-x`**.

You can now proceed to enable **VLAN filtering** by executing the following
commands:

```bash
# Note: Press [CTRL-x] In the terminal prompt, after the prompt line, you must see <SAFE> text

# Enable VLAN filtering
/interface/bridge
set [find where name="bridge"] vlan-filtering=yes
```

---

### Useful Tools

#### Logs

Display real-time logs:

```bash
/log/print follow
```

Filter logs by keyword:

```bash
/log/print where message~"BAN"
```

```text
14:33:48 firewall,info BAN INPUT 80 input: in:ether1 out:(unknown 0), connection-state:new src-mac aa:bb:cc:dd:dd:ee, proto TCP (SYN), 80.75.212.9:50264->192.168.0.88:80, len 40
14:37:55 firewall,info BAN INPUT 80 input: in:ether1 out:(unknown 0), connection-state:new src-mac aa:bb:cc:dd:dd:ee, proto TCP (SYN), 62.169.22.37:40244->192.168.0.88:80, len 40
15:13:31 firewall,info BAN INPUT 80 input: in:ether1 out:(unknown 0), connection-state:new src-mac aa:bb:cc:dd:dd:ee, proto TCP (SYN), 194.50.16.198:57018->192.168.0.88:80, len 40
15:22:55 firewall,info BAN INPUT 80 input: in:ether1 out:(unknown 0), connection-state:new src-mac aa:bb:cc:dd:dd:ee, proto TCP (SYN), 93.174.93.12:60000->192.168.0.88:80, len 40
```

#### Ping

Test an IP address:

```bash
/tool/ping address=8.8.8.8 count=5
```

```text
SEQ HOST                                     SIZE TTL TIME       STATUS                                                                                                                   
  0 8.8.8.8                                    56 249 27ms336us 
  1 8.8.8.8                                    56 249 28ms654us 
  2 8.8.8.8                                    56 249 28ms473us 
  3 8.8.8.8                                    56 249 28ms657us 
  4 8.8.8.8                                    56 249 28ms434us
```

#### Sniffer

Capture network traffic on an interface:

```bash
/tool/sniffer/quick duration=1
```

```text
INTERFACE  TIME   NUM  DIR  SRC-MAC            DST-MAC            VLAN  SRC-ADDRESS                 DST-ADDRESS                 PROTOCOL  SIZE  CPU
ether2     0.904  668  <-   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee   254  192.168.254.114:33842       142.251.37.234:443 (https)  ip:tcp     109    0
bridge     0.904  669  <-   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee   254  192.168.254.114:33842       142.251.37.234:443 (https)  ip:tcp     109    0
vlan-lan   0.904  670  <-   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee        192.168.254.114:33842       142.251.37.234:443 (https)  ip:tcp     105    0
ether1     0.904  671  ->   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee        192.168.88.22:33842         142.251.37.234:443 (https)  ip:tcp     105    0
ether1     0.919  672  <-   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee        140.82.121.3                192.168.88.22               ip:icmp     98    0
vlan-lan   0.919  673  ->   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee        140.82.121.3                192.168.254.100             ip:icmp     98    0
bridge     0.919  674  ->   aa:bb:cc:dd:dd:ee  aa:bb:cc:dd:dd:ee   254  140.82.121.3                192.168.254.100             ip:icmp    102    0
```

#### Torch

Analyze live network flows:

```bash
/tool/torch interface=ether1 src-address=0.0.0.0/0 dst-address=0.0.0.0/0 ip-protocol=any mac-protocol=any
```

```text
MAC-PROTOCOL  IP-PROTOCOL  SRC-ADDRESS     DST-ADDRESS   TX        RX         TX-PACKETS  RX-PACKETS
ip            icmp         140.82.121.3    192.168.88.22  784bps    784bps              1           1
ip            icmp         142.251.37.227  192.168.88.22  784bps    784bps              1           1
ip            icmp         192.168.0.1     192.168.88.22  41.9kbps  41.9kbps            5           5
ip            tcp          18.197.249.189  192.168.88.22  1488bps   976bps              2           1
ip            tcp          45.45.148.7     192.168.88.22  1248bps   1728bps             2           3
ip            tcp          71.18.255.144   192.168.88.22  17.6kbps  51.3kbps            9          11
```

#### System Resources

Displaying router resources:

```bash
/system/resource print
```

```text
                 uptime: 1d23h10m42s
                version: 7.14.1 (stable)
             build-time: 2024-03-08 12:50:23
       factory-software: 6.44.6
            free-memory: 906.9MiB
           total-memory: 1024.0MiB
                    cpu: ARM
              cpu-count: 4
          cpu-frequency: 533MHz
               cpu-load: 0%
         free-hdd-space: 418.5MiB
        total-hdd-space: 512.0MiB
write-sect-since-reboot: 140623
       write-sect-total: 1569203
             bad-blocks: 0%
      architecture-name: arm
             board-name: RB4011iGS+5HacQ2HnD
               platform: MikroTik
```

#### Package Update

Displaying package version and updating:

```bash
/system package update check-for-updates
```

```text
          channel: stable
installed-version: 7.14.1
   latest-version: 7.16.2
           status: New version is available
```

Installing the update:

```bash
/system package update install
```

#### RouterOS Update

Displaying RouterOS version and updating:

```bash
/system routerboard print
```

```text
     routerboard: yes
           model: RB4011iGS+5HacQ2HnD
        revision: r2
   serial-number: D43B0C96671D
   serial-number: DXXXXXXXXXXX
   firmware-type: al2
factory-firmware: 6.45.9
current-firmware: 6.45.9
upgrade-firmware: 7.16.2
```

Updating and restarting:

```bash
/system routerboard upgrade 
/system reboot
```

---

## Sources

- Websites:
  - [en.wikipedia.org](https://en.wikipedia.org)
  - [help.mikrotik.com](https://help.mikrotik.com)
  - [mikrotik.com](https://mikrotik.com)
- [AI](/en/#clarification-on-the-use-of-ai)
  - openai
    - Translation from the French language
