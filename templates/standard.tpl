#cloud-config
# set locale
locale: en_GB.UTF-8
# ensure time sync between all nodes
ntp:
  enabled: true
  ntp_client: chrony
# hides ssh keys in console
ssh_fp_console_blacklist: [ssh-dss, ssh-dsa, ssh-ed25519]
ssh_key_console_blacklist: [ssh-dss, ssh-dsa, ssh-ed25519]

# upgrade all packages and install necessary ones
package_upgrade: true
package_reboot_if_required: true
packages:
- apt-transport-https
- build-essential
- ca-certificates
- curl
- gnupg-agent
- libssl-dev
- locate
- make
- software-properties-common

# set random root password and disable password login for ssh
chpasswd:
  expire: false
  list: |
      root:RANDOM
ssh_pwauth: no

# create sre user with sudo privs and set autrhorized key
users:
- name: sre
  groups: sudo
  lock_passwd: true
  ssh_authorized_keys:
   - PUBLICKEY
  sudo: ['ALL=(ALL) NOPASSWD:ALL']
  shell: /bin/bash

runcmd:
- cd /root/
- wget https://github.com/hetznercloud/cli/releases/download/v1.17.0/hcloud-linux-amd64.tar.gz
- tar xf hcloud-linux-amd64.tar.gz hcloud
- mv hcloud /usr/local/bin/
