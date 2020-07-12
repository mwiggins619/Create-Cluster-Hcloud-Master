provider "hcloud" {
  token = var.hcloud_token
}

data "template_file" "standard_template" {
  template = file("${path.module}/templates/standard.tpl")
}

resource "hcloud_floating_ip" "lb_vip" {
  name          = "lbvip"
  home_location = var.location
  type          = "ipv4"
}

resource "hcloud_network" "k8s" {
  name     = "kubernetes"
  ip_range = "192.168.0.0/16"
}

resource "hcloud_network_subnet" "lb" {
  network_id   = hcloud_network.k8s.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "192.168.1.0/28"
}

resource "hcloud_network_subnet" "k8s_subnet" {
  network_id   = hcloud_network.k8s.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "192.168.0.0/28"
}


output "keepalived_output" {
  value = [data.template_file.keepalived_template.*.rendered]
}

output "cloud_init_output" {
  value = [data.cloudinit_config.lb_user_data.*.rendered]
}

resource "hcloud_server_network" "lb_network" {
  count      = length(hcloud_server.lb)
  server_id  = hcloud_server.lb.*.id[count.index]
  network_id = hcloud_network.k8s.id
  ip         = "192.168.1.${count.index + 2}"
}

resource "hcloud_server_network" "master_0_network" {
  server_id  = hcloud_server.master_0.id
  network_id = hcloud_network.k8s.id
  ip         = "192.168.0.2"
}

resource "hcloud_server_network" "other_masters_network" {
  count      = length(hcloud_server.other_masters)
  server_id  = hcloud_server.other_masters.*.id[count.index]
  network_id = hcloud_network.k8s.id
  ip         = "192.168.0.${count.index + 3}"
  depends_on = [
    hcloud_server.other_masters
  ]
}

resource "hcloud_server_network" "workers_network" {
  count      = var.worker_count
  server_id  = hcloud_server.workers.*.id[count.index]
  network_id = hcloud_network.k8s.id
  ip         = "192.168.0.${count.index + 10}"
  depends_on = [
    hcloud_server.other_masters
  ]
}

output "lb_ips" {
  value = [hcloud_server.lb.*.ipv4_address]
}

output "lb_vip" {
  value = [hcloud_floating_ip.lb_vip.ip_address]
}

output "master_0_ip" {
  value = [hcloud_server.master_0.ipv4_address]
}

output "other_masters_ips" {
  value = [hcloud_server.other_masters.*.ipv4_address]
}

output "workers_ips" {
  value = [hcloud_server.workers.*.ipv4_address]
}
