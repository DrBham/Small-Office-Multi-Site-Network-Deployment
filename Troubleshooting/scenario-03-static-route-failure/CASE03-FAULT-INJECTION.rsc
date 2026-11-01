# 2026-11-01 14:22:37 by RouterOS 7.23.8
# system id = cAAqUZvkAWN
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip address
add address=10.255.10.2/30 interface=ether2 network=10.255.10.0
add address=10.255.10.5/30 interface=ether3 network=10.255.10.4
/ip dhcp-client
add interface=ether1 name=client1
/ip firewall filter
add action=accept chain=input comment=\
    "NDS-ISP-INPUT-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=input comment="NDS-ISP-INPUT-02 Drop Invalid" \
    connection-state=invalid
add action=accept chain=input comment=\
    "NDS-ISP-INPUT-03 Allow WinBox Management" dst-port=8291 in-interface=\
    ether1 protocol=tcp src-address=192.168.56.0/24
add action=accept chain=input comment="NDS-ISP-INPUT-04 Allow SSH Management" \
    dst-port=22 in-interface=ether1 protocol=tcp src-address=192.168.56.0/24
add action=accept chain=input comment=\
    "NDS-ISP-INPUT-05 Allow ICMP HQ Neighbor" in-interface=ether2 protocol=\
    icmp src-address=10.255.10.1
add action=accept chain=input comment=\
    "NDS-ISP-INPUT-06 Allow ICMP Branch Neighbor" in-interface=ether3 \
    protocol=icmp src-address=10.255.10.6
add action=drop chain=input comment="NDS-ISP-INPUT-07 Default Drop"
add action=accept chain=forward comment=\
    "NDS-ISP-FWD-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="NDS-ISP-FWD-02 Drop Invalid" \
    connection-state=invalid
add action=accept chain=forward comment=\
    "NDS-ISP-FWD-03 Allow HQ to Branch ICMP" connection-state=new \
    dst-address=172.22.20.0/27 in-interface=ether2 out-interface=ether3 \
    protocol=icmp src-address=172.22.10.0/26
add action=accept chain=forward comment=\
    "NDS-ISP-FWD-04 Allow Branch to HQ ICMP" connection-state=new \
    dst-address=172.22.10.0/26 in-interface=ether3 out-interface=ether2 \
    protocol=icmp src-address=172.22.20.0/27
add action=accept chain=forward comment=\
    "NDS-ISP-FWD-05 Allow Branch Direct HTTP" connection-state=new \
    dst-address=172.22.10.10 dst-port=80 in-interface=ether3 out-interface=\
    ether2 protocol=tcp src-address=172.22.20.0/27
add action=accept chain=forward comment=\
    "NDS-ISP-FWD-06 Allow Branch HQ WAN HTTP" connection-state=new \
    dst-address=10.255.10.1 dst-port=80 in-interface=ether3 out-interface=\
    ether2 protocol=tcp src-address=172.22.20.0/27
add action=drop chain=forward comment="NDS-ISP-FWD-07 Default Drop"
/ip route
add disabled=no distance=1 dst-address=172.22.10.0/26 gateway=10.255.10.9 \
    routing-table=main
add disabled=no distance=1 dst-address=172.22.20.0/27 gateway=10.255.10.6 \
    routing-table=main
/ip service
set ftp disabled=yes
set ssh address=192.168.56.0/24
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox address=192.168.56.0/24
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=NDS-CHR-ISP
