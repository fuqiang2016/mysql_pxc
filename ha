1.lvs配置
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore  
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce  
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore  
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

ifconfig lo:0 10.0.104.116 netmask 255.255.255.255
route add -host 10.0.104.116 dev lo

vim /etc/sysctl.d/ha.conf
vm.swappiness = 0 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
