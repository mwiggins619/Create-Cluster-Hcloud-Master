#!/bin/bash

set -ex

HCLOUD_TOKEN=${1}
VIP=${2}

SELF=`hcloud server describe $(hostname) | head -n 1 | sed 's/[^0-9]*//g'`

VIP_SERVER_ID=`hcloud floating-ip describe ${VIP} | grep 'Server:' -A 1 | tail -n 1 | sed 's/[^0-9]*//g'`

if [ "${VIP_SERVER_ID}" != "${SELF}" ] ; then
  n=0
  while [ $n -lt 10 ]
  do
    hcloud floating-ip assign ${VIP} ${SELF} && break
    n=$((n+1))
    sleep 3
  done
fi

