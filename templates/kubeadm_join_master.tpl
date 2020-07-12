write_files:
- encoding: b64
  content: ${APISERVER_AUDIT_POLICY}
  owner: root:root
  path: /etc/kubernetes/audit-policy/apiserver-audit-policy.yaml
  permissions: '0655'
- encoding: b64
  content: ${KUBEADM_JOIN}
  owner: root:root
  path: /home/sre/kubeadm_join
  permissions: '0755'
runcmd:
- export HCLOUD_TOKEN=${HCLOUD_TOKEN}
- hcloud server attach-to-network --ip ${PRIVATE_IP} --network ${NETWORK_ID} ${SERVER_NAME}
- eval $(tail -n 1 /home/sre/kubeadm_join)
