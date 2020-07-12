#cloud-config
packages:
- haproxy
write_files:
- encoding: b64
  content: ${KEEPALIVED_SERVICE}
  owner: root:root
  path: /etc/systemd/system/keepalived.service
  permissions: '0644'
- encoding: b64
  content: ${KEEPALIVED_CONF} 
  owner: root:root
  path: /etc/keepalived/keepalived.conf
  permissions: '0644'
- encoding: b64
  content: ${MASTER_SCRIPT}
  owner: root:root
  path: /etc/keepalived/master.sh
  permissions: '0755'
- encoding: b64
  content: ${HAPROXY_CFG}
  owner: root:root
  path: /etc/haproxy/haproxy.cfg
  permissions: '0644'
runcmd:
- wget http://www.keepalived.org/software/keepalived-2.1.2.tar.gz
- tar xf keepalived-2.1.2.tar.gz
- cd keepalived-2.1.2
- ./configure
- make
- sudo make install
- sudo systemctl enable keepalived
- sudo systemctl start keepalived
- rm -rf /root/*.tar.gz
- updatedb
final_message: "The system is finally up, after $UPTIME seconds"
