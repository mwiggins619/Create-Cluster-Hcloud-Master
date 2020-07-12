#!/usr/bin/env bash
set -ex

export HCLOUD_TOKEN=${HCLOUD_TOKEN}

# Attach private network to node
hcloud server attach-to-network --ip 192.168.0.2 --network ${NETWORK_ID} master-0

# Initialize Cluster
kubeadm init --config /home/sre/config.yaml

# Prepare files for scp script
kubeadm token create --print-join-command > /home/sre/kubeadm_join
kubeadm init phase upload-certs --upload-certs | tail -n 1 > /home/sre/certificate_key
echo $(cat /home/sre/kubeadm_join) --control-plane --certificate-key $(cat /home/sre/certificate_key) >> /home/sre/kubeadm_join

mkdir -p /home/sre/.kube
cp /etc/kubernetes/admin.conf /home/sre/.kube/config
chown -R sre:sre /home/sre

# Setup hcloud specific control plane and calico
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl -n kube-system create secret generic hcloud --from-literal=token=${HCLOUD_TOKEN} --from-literal=network=${NETWORK_ID}
kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${HCLOUD_TOKEN}
kubectl -n kube-system patch deployment coredns --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/hcloud-cloud-controller-manager/master/deploy/v1.6.1-networks.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl -n kube-system patch deployment calico-kube-controllers --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v1.4.0/deploy/kubernetes/hcloud-csi.yml
