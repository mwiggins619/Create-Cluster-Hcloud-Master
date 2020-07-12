#cloud-config
apt:
  preserve_sources_list: true
  sources:
    devel_kubic_libcontainers_stable:
      # get this with apt-key adv --list-public-keys --with-fingerprint --with-colons (is last 8 chars of fingerprint)
      keyid: '75060AA4'
      keyurl: 'https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${OS_NAME}_${VERSION_ID}/Release.key'
      source: 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${OS_NAME}_${VERSION_ID}/ /'
write_files:
- encoding: b64
  content: b3ZlcmxheQpicl9uZXRmaWx0ZXIK
  owner: root:root
  path: /etc/modules-load.d/containerd.conf
  permissions: '0644'
runcmd:
- modprobe overlay
- modprobe br_netfilter
- sed -i "s/-net.ipv4.conf.all.promote_secondaries/-net.ipv4.conf.all.promote_secondaries = 1/g" /usr/lib/sysctl.d/50-default.conf
- sysctl --system
- export CRIO_VERSION=${CRIO_VERSION}
- apt-get -qq update
- apt-get -qq install -y runc cri-o-${CRIO_VERSION} cri-o-runc conntrack
- apt-mark hold cri-o-${CRIO_VERSION}
- systemctl enable crio.service
- systemctl restart crio.service
