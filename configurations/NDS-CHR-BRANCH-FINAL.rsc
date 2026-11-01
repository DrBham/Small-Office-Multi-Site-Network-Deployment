# 2026-11-01 15:01:57 by RouterOS 7.23.8
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip pool
add name=POOL-BRANCH-LAN ranges=172.22.20.10-172.22.20.29
/ip dhcp-server
add address-pool=POOL-BRANCH-LAN interface=ether3 lease-time=1d name=\
    DHCP-BRANCH-LAN
/ip address
add address=10.255.10.6/30 interface=ether2 network=10.255.10.4
add address=172.22.20.1/27 interface=ether3 network=172.22.20.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dhcp-server network
add address=172.22.20.0/27 gateway=172.22.20.1
/ip firewall filter
add action=accept chain=input comment=\
    "NDS-BR-INPUT-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=input comment="NDS-BR-INPUT-02 Drop Invalid" \
    connection-state=invalid
add action=accept chain=input comment=\
    "NDS-BR-INPUT-03 Allow WinBox Management" dst-port=8291 in-interface=\
    ether1 protocol=tcp src-address=192.168.56.0/24
add action=accept chain=input comment="NDS-BR-INPUT-04 Allow SSH Management" \
    dst-port=22 in-interface=ether1 protocol=tcp src-address=192.168.56.0/24
add action=accept chain=input comment="NDS-BR-INPUT-05 Allow DHCP Branch" \
    dst-port=67 in-interface=ether3 protocol=udp
add action=accept chain=input comment="NDS-BR-INPUT-06 Allow ICMP Branch LAN" \
    in-interface=ether3 protocol=icmp src-address=172.22.20.0/27
add action=accept chain=input comment="NDS-BR-INPUT-07 Allow ICMP HQ LAN" \
    in-interface=ether2 protocol=icmp src-address=172.22.10.0/26
add action=accept chain=input comment=\
    "NDS-BR-INPUT-08 Allow ICMP ISP Neighbor" in-interface=ether2 protocol=\
    icmp src-address=10.255.10.5
add action=drop chain=input comment="NDS-BR-INPUT-09 Default Drop"
add action=accept chain=forward comment=\
    "NDS-BR-FWD-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="NDS-BR-FWD-02 Drop Invalid" \
    connection-state=invalid
add action=accept chain=forward comment=\
    "NDS-BR-FWD-03 Allow Branch to HQ ICMP" connection-state=new dst-address=\
    172.22.10.0/26 in-interface=ether3 out-interface=ether2 protocol=icmp \
    src-address=172.22.20.0/27
add action=accept chain=forward comment=\
    "NDS-BR-FWD-04 Allow HQ to Branch ICMP" connection-state=new dst-address=\
    172.22.20.0/27 in-interface=ether2 out-interface=ether3 protocol=icmp \
    src-address=172.22.10.0/26
add action=accept chain=forward comment=\
    "NDS-BR-FWD-05 Allow Branch Direct HTTP" connection-state=new \
    dst-address=172.22.10.10 dst-port=80 in-interface=ether3 out-interface=\
    ether2 protocol=tcp src-address=172.22.20.0/27
add action=accept chain=forward comment=\
    "NDS-BR-FWD-06 Allow Branch HQ WAN HTTP" connection-state=new \
    dst-address=10.255.10.1 dst-port=80 in-interface=ether3 out-interface=\
    ether2 protocol=tcp src-address=172.22.20.0/27
add action=drop chain=forward comment="NDS-BR-FWD-07 Default Drop"
/ip route
add disabled=no distance=1 dst-address=172.22.10.0/26 gateway=10.255.10.5 \
    routing-table=main
add comment="NDS-TEST Route to HQ WAN for DST-NAT" disabled=no distance=1 \
    dst-address=10.255.10.1/32 gateway=10.255.10.5 routing-table=main
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
set name=NDS-CHR-BRANCH
