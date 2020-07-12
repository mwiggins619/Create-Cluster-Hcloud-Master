#!/bin/bash
set -eu
SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}
SSH_USERNAME=${SSH_USERNAME:-}
SSH_HOST=${SSH_HOST:-}

TARGET=${TARGET:-}

sleep 400

mkdir -p "${TARGET}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST}:/home/sre/kubeadm_join" \
    "${TARGET}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST}:/home/sre/.kube/config" \
    "${TARGET}"

