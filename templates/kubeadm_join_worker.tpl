write_files:
- encoding: b64
  content: ${KUBEADM_JOIN}
  owner: root:root
  path: /home/sre/kubeadm_join
  permissions: '0755'
runcmd:
- export HCLOUD_TOKEN=${HCLOUD_TOKEN}
- hcloud server attach-to-network --ip ${PRIVATE_IP} --network ${NETWORK_ID} ${SERVER_NAME}
- eval $(head -n 1 /home/sre/kubeadm_join)
