#cloud-config
write_files:
- encoding: b64
  content: ${APISERVER_AUDIT_POLICY}
  owner: root:root
  path: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml 
  permissions: '0655'
- encoding: b64
  content: ${KUBEADM_INIT}
  owner: root:root
  path: /home/sre/config.yaml
  permissions: '0655'
- encoding: b64
  content: ${KUBEADM_SH}
  owner: root:root
  path: /home/sre/kubeadm.sh
  permissions: '0755'
runcmd:
- /home/sre/kubeadm.sh

