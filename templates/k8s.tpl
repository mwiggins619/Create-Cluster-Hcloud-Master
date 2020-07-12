#cloud-config
apt:
  preserve_sources_list: true
  sources:
    kubernetes:
      keyid: 'BA07F4FB'
      keyserver: 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
      source: 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
write_files:
- encoding: b64
  content: ${KUBERNETES_CRI_CONF}
  owner: root:root
  path: /etc/sysctl.d/99-kubernetes-cri.conf
  permissions: '0644'
- encoding: b64
  content: ${CGROUPS_CONF}
  owner: root:root
  path: /etc/systemd/system/kubelet.service.d/11-cgroups.conf
  permissions: '0644'
- encoding: b64
  content: ${HCLOUD_CONF}
  owner: root:root
  path: /etc/systemd/system/kubelet.service.d/20-hcloud.conf
  permissions: '0644'
runcmd:
- export KUBERNETES_VERSION=${KUBERNETES_VERSION}
- apt-get -qq update
- apt-get -qq -o DPkg::Options::="--force-confold" install -y kubelet kubeadm
- apt-mark hold kubelet kubeadm
- systemctl daemon-reload
- systemctl restart kubelet 
