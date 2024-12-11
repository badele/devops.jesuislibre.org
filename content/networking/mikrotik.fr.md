---
title: Routeur MikroTik
---

{{< hint type="note" title="Introduction" >}}

Les routeurs [MikroTik](https://mikrotik.com/) offrent des solutions
professionnelles à des prix abordables, idéales pour une utilisation
personnelle. Que ce soit pour des routeurs, switchs ou points d'accès Wi-Fi, ils
fonctionnent tous sous [RouterOS](https://mikrotik.com/software). Peu importe le
périphérique, chaque modèle peut remplir les rôles de routeur, pare-feu et
switch. Vous pouvez ainsi débuter avec un modèle comme le
[hEX lite](https://mikrotik.com/product/RB750r2), disponible pour environ
**40€**.

{{< /hint >}}

{{< hint type=tip title=Conseil >}}

Il est également possible de tester RouterOS sur une
[machine virtuelle](https://mikrotik.com/software) pendant 24 heures.

{{< /hint >}}

{{< toc >}}

## Caractéristiques

Les routeurs MikroTik proposent les fonctionnalités suivantes :

- **Réseau :**
  - [Bridge](https://help.mikrotik.com/docs/spaces/ROS/pages/328068/Bridging+and+Switching)
  - [VLAN](https://help.mikrotik.com/docs/spaces/ROS/pages/88014957/VLAN)
  - QoS
    ([Hardware](https://help.mikrotik.com/docs/spaces/ROS/pages/11993091/QoS+with+Switch+Chip)
    / Software)
  - Serveur DHCP
  - Commutation
    ([STP, RSTP](https://help.mikrotik.com/docs/spaces/ROS/pages/21725254/Spanning+Tree+Protocol#SpanningTreeProtocol-STPandRSTP))
- **Routage :**
  - Routage statique et dynamique
    ([OSPF](https://fr.wikipedia.org/wiki/Open_Shortest_Path_First),
    [BGP](https://fr.wikipedia.org/wiki/Border_Gateway_Protocol),
    [RIP](https://fr.wikipedia.org/wiki/Routing_Information_Protocol),
    [MPLS](https://fr.wikipedia.org/wiki/Multiprotocol_Label_Switching))
  - [Load Balancing](https://help.mikrotik.com/docs/spaces/ROS/pages/4390920/Load+Balancing)
  - [Failover](https://help.mikrotik.com/docs/spaces/ROS/pages/26476608/Failover+WAN+Backup)
- **Sécurité :**
  - Pare-feu
    ([Protection DDoS](https://help.mikrotik.com/docs/spaces/ROS/pages/28606504/DDoS+Protection),
    [Port knocking](https://help.mikrotik.com/docs/spaces/ROS/pages/154042369/Port+knocking))
  - VPN
    ([IPsec](https://help.mikrotik.com/docs/spaces/ROS/pages/11993097/IPsec),
    [OpenVPN](https://help.mikrotik.com/docs/spaces/ROS/pages/2031655/OpenVPN),
    [SSTP](https://help.mikrotik.com/docs/spaces/ROS/pages/2031645/SSTP),
    [WireGuard](https://help.mikrotik.com/docs/spaces/ROS/pages/69664792/WireGuard))
- **Wi-Fi :**
  - ([AP Controller](https://help.mikrotik.com/docs/spaces/ROS/pages/1409149/AP+Controller+CAPsMAN),
    [Hotspot](https://help.mikrotik.com/docs/spaces/ROS/pages/56459266/HotSpot+-+Captive+portal))

Pour plus d'informations, consultez la
[documentation officielle](https://help.mikrotik.com/docs/spaces/ROS/pages/19136707/Software+Specifications).

---

## Fonctionnalités en détail

### Safe Mode

{{< hint type="important">}}

Le **Safe Mode** protège contre les erreurs de configuration pouvant entraîner
une perte d'accès.

{{< /hint >}}

Depuis la ligne de commande, appuyez sur **`CTRL-x`** pour activer ce mode,
identifiable par l'indication **`<SAFE>`** dans l'invite.

**Comment ça fonctionne ?**

En mode Safe Mode, le routeur teste périodiquement la connectivité entre
lui-même et la session SSH de l'administrateur. Si une perte de connexion est
détectée, il restaure la configuration précédente.

Pour sauvegarder vos modifications tout en restant connecté, désactivez le Safe
Mode en appuyant de nouveau sur **`CTRL-x`**.

---

### Firewall

Les routeurs MikroTik intègrent deux types de pare-feu : Layer 2 et Layer 3.

#### Exemple Layer 3

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

Les VLAN permettent d’isoler plusieurs flux réseau au sein du même bridge. Cela
permet, par exemple, de séparer le trafic entre le LAN et une DMZ sans
interaction entre eux. Voici deux notions importantes :

- **Tagged (trunk)** : Ajout d’un numéro VLAN dans l’en-tête Ethernet du paquet
  IP, pour les périphériques compatibles
  ([802.1Q](https://fr.wikipedia.org/wiki/IEEE_802.1Q)).
- **Untagged** : Suppression du numéro VLAN pour rendre le paquet accessible aux
  périphériques classiques.

#### Exemple

L’exemple suivant configure deux VLANs : **LAN (2)** et **DMZ (3)**. Tous les
ports sont dédiés au LAN, sauf :

- `ether10` pour la DMZ.
- `ether2`, utilisé comme trunk (tagged) pour transporter les flux LAN et DMZ.

```bash
# Désactiver temporairement le filtrage VLAN
/interface/bridge
set [find where name="bridge"] vlan-filtering=no

# Associer tous les ports au VLAN-LAN (PVID 2)
/interface/bridge/port
set [find] pvid=2

# Associer ether10 au VLAN-DMZ (PVID 3)
set [find where interface=ether10] pvid=3

# Configurer le trunk (ether2)
/interface/bridge/vlan
add bridge=bridge comment=eth2-lan tagged=ether2,bridge vlan-ids=2
add bridge=bridge comment=eth2-dmz tagged=ether2,bridge vlan-ids=3

# Créer les interfaces VLAN
/interface/vlan
add interface=bridge name=vlan-lan vlan-id=2
add interface=bridge name=vlan-dmz vlan-id=3

# Adressage IP
/ip/address
add address=192.168.2.254/24 interface=vlan-lan
add address=192.168.3.254/24 interface=vlan-dmz

# Configurer les pools DHCP
/ip/pool
add name=dhcp-lan ranges=192.168.2.128/25
add name=dhcp-dmz ranges=192.168.3.128/25

# Ajouter les serveurs DHCP
/ip/dhcp-server
add address-pool=dhcp-lan interface=vlan-lan
add address-pool=dhcp-dmz interface=vlan-dmz
```

##### Application de la configuration

Pour préserver l’ensemble de la configuration précédente (étant toujours en mode
`<SAFE>`), je resort du safe mode en pressant es touches **CTRL-x**.

Je peux dorénavant passer à l'activation du **VLAN filtering**, en executant les
commandes suivantes (en n'oubliant pas d'activer le save mode):

```bash
# Note: Press [CTRL-x] In the terminal prompt, after the prompt line, you must see <SAFE> text

# Enable vlan filtering
/interface/bridge
set [find where name="bridge"] ] vlan-filtering=yes
```

---

### Outils pratiques

#### Logs

Afficher les logs en temps réel :

```bash
/log/print follow
```

Filtrer les logs par mot-clé :

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

Tester une adresse IP :

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

Capturer le trafic réseau sur une interface :

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

Analyser les flux réseau en direct :

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

Affichage des ressources du routeur :

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

#### Mise à Jour des Packages

Affichage de la version des packages et mise à jour :

```bash
/system package update check-for-updates
```

```text
          channel: stable
installed-version: 7.14.1
   latest-version: 7.16.2
           status: New version is available
```

Installation de la mise à jour :

```bash
/system package update install
```

#### Mise à Jour du RouterOS

Affichage de la version du RouterOS et mise à jour :

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

Mise à jour et redémarrage :

```bash
/system routerboard upgrade 
/system reboot
```

---

## Sources

- Site webs
  - [fr.wikipedia.org](https://fr.wikipedia.org)
  - [help.mikrotik.com](https://help.mikrotik.com)
  - [mikrotik.com](https://mikrotik.com)
- [IA](/#clarification-sur-lutilisation-de-lia)
  - openai
    - Reformulation des phrases
    - Correction des fautes d'orthographe

```
```

```
```
