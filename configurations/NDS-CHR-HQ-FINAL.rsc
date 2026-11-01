# 2026-11-01 15:01:05 by RouterOS 7.23.8
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
/ip pool
add name=POOL-HQ_LAN ranges=172.22.10.20-172.22.10.59
/ip dhcp-server
add address-pool=POOL-HQ_LAN interface=ether3 lease-time=1d name=DHCP-HQ-LAN
/ip address
add address=10.255.10.1/30 interface=ether2 network=10.255.10.0
add address=172.22.10.1/26 interface=ether3 network=172.22.10.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dhcp-server network
add address=172.22.10.0/26 gateway=172.22.10.1
/ip firewall filter
add action=accept chain=input comment=\
    "NDS-INPUT-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=input comment="NDS-INPUT-08 Drop Invalid" \
    connection-state=invalid
add action=accept chain=input comment="NDS-INPUT-02 Allow WinBox Management" \
    dst-port=8291 in-interface=ether1 protocol=tcp src-address=\
    192.168.56.0/24
add action=accept chain=input comment="NDS-INPUT-03 Allow SSH Management" \
    dst-port=22 in-interface=ether1 protocol=tcp src-address=192.168.56.0/24
add action=accept chain=input comment="NDS-INPUT-04 Allow DHCP HQ" dst-port=\
    67 in-interface=ether3 protocol=udp
add action=accept chain=input comment="NDS-INPUT-05 Allow ICMP HQ LAN" \
    in-interface=ether3 protocol=icmp src-address=172.22.10.0/26
add action=accept chain=input comment="NDS-INPUT-06 Allow ICMP Branch" \
    in-interface=ether2 protocol=icmp src-address=172.22.20.0/27
add action=accept chain=input comment="NDS-INPUT-07 Allow ICMP ISP Neighbor" \
    in-interface=ether2 protocol=icmp src-address=10.255.10.2
add action=drop chain=input comment="NDS-INPUT-09 Default Drop"
add action=accept chain=forward comment=\
    "NDS-FWD-01 Allow Established Related" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="NDS-FWD-02 Drop Invalid" \
    connection-state=invalid
add action=accept chain=forward comment="NDS-FWD-03 Allow HQ to Branch ICMP" \
    connection-state=new dst-address=172.22.20.0/27 in-interface=ether3 \
    out-interface=ether2 protocol=icmp src-address=172.22.10.0/26
add action=accept chain=forward comment="NDS-FWD-04 Allow Branch to HQ ICMP" \
    connection-state=new dst-address=172.22.10.0/26 in-interface=ether2 \
    out-interface=ether3 protocol=icmp src-address=172.22.20.0/27 \
    src-address-list=""
add action=accept chain=forward comment="NDS-FWD-05 Allow Branch HTTP" \
    connection-nat-state=!dstnat connection-state=new dst-address=\
    172.22.10.10 dst-port=80 in-interface=ether2 out-interface=ether3 \
    protocol=tcp src-address=172.22.20.0/27
add action=accept chain=forward comment="NDS-FWD-06 Allow DST-NAT HTTP" \
    connection-nat-state=dstnat connection-state=new dst-address=172.22.10.10 \
    dst-port=80 in-interface=ether2 out-interface=ether3 protocol=tcp
add action=drop chain=forward comment="NDS-FWD-07 Default Drop"
/ip firewall nat
add action=dst-nat chain=dstnat comment="NDS-NAT-01 Port Forward HTTP" \
    dst-address=10.255.10.1 dst-port=80 in-interface=ether2 protocol=tcp \
    src-address=172.22.20.0/27 to-addresses=172.22.10.10 to-ports=80
/ip route
add disabled=no distance=1 dst-address=172.22.20.0/27 gateway=10.255.10.2 \
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
set name=NDS-CHR-HQ
