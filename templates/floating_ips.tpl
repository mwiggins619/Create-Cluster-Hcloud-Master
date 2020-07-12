#cloud-config
write_files:
- content: |
    network:
      version: 2
      ethernets:
        eth0:
          addresses:
           - ${VIP}/32
  path: /etc/netplan/60-floating-ip.yaml

