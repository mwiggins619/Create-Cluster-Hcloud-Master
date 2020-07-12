global_defs {
  script_user root
  enable_script_security
  max_auto_priority 1
}
vrrp_script chk_haproxy {
  script "/usr/bin/pgrep haproxy"
  interval 2
}
vrrp_instance LB_1 {
%{~ if PRIORITY - SERVER_COUNT == 200 }
    state MASTER
%{else}
    state BACKUP
%{ endif ~}
    interface eth0
    virtual_router_id 69
    priority ${PRIORITY}
    advert_int 1
%{~ if PRIORITY - SERVER_COUNT == 200 }
    unicast_src_ip 192.168.1.2
    unicast_peer {
      192.168.1.3
%{else}
    unicast_src_ip 192.168.1.3
    unicast_peer {
      192.168.1.2
%{ endif ~}
    }
    authentication {
      auth_type PASS
      auth_pass ${KEEPALIVED_PASSWORD}
    }
    virtual_ipaddress {
      ${VIP}
    }
    track_script {
      chk_haproxy
    }
    notify_master "/etc/keepalived/master.sh ${VIP}"
}
