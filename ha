1.lvs配置
1.1 配置内核参数及路由
  cat <<EOF > /etc/sysctl.d/ha.conf
    vm.swappiness = 0 \ 
    net.bridge.bridge-nf-call-ip6tables = 1 \
    net.bridge.bridge-nf-call-iptables = 1 \
    net.ipv4.ip_forward = 1 
    EOF
    modprobe br_netfilter
  
  cat > /etc/sysconfig/modules/ipvs.modules <<EOF
  #!/bin/bash
  modprobe -- ip_vs
  modprobe -- ip_vs_rr
  modprobe -- ip_vs_wrr
  modprobe -- ip_vs_sh
  modprobe -- nf_conntrack_ipv4
  EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
  
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore  
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce  
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore  
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

ifconfig lo:0 10.0.104.116 netmask 255.255.255.255
route add -host 10.0.104.116 dev lo

1.2 安装lvs
yum install ipset ipvsadm -y

1.3 查看lvs
ipvsadm -lnc
ipvsadm -ln --stats

2.keepalived
2.1 安装keepalived
yum install -y keepalived
2.2 配置keepalived
vim /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
   router_id LVS_MASTER            #BACKUP  LVS_BACKUP
}

vrrp_instance VI_1 {
    state MASTER                   #BACKUP  
    interface ens160
    virtual_router_id 51           #主备必须一致
    priority 100                   #BACKUP  80
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {             #定义虚拟服务地址
        10.0.104.116
    }
}

virtual_server 10.0.104.116 3306 {  #定义虚拟服务配置
    delay_loop 6
    lb_algo rr
    lb_kind dr
    protocol TCP

    real_server 10.0.104.113 3306 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 3306
        }
    }
    real_server 10.0.104.114 3306 {
            weight 3
            TCP_CHECK {
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
                connect_port 3306
            }
        }

    real_server 10.0.104.115 3306 {
        weight 3
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 3306
        }
    }
}

2.3 启动keepalived
systemctl enable keepalived && systemctl start keepalived



