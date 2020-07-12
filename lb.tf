data "template_file" "lb_vip_template" {
  template = file("${path.module}/templates/floating_ips.tpl")
  vars = {
    VIP = "${hcloud_floating_ip.lb_vip.ip_address}"
  }
}

resource "random_password" "keepalived_password" {
  length           = 8
  special          = true
  override_special = "_%@"
}

data "template_file" "keepalived_template" {
  count    = 2
  template = file("${path.module}/templates/keepalived.tpl")
  vars = {
    HCLOUD_TOKEN        = var.hcloud_token
    KEEPALIVED_PASSWORD = "${random_password.keepalived_password.result}"
    PRIORITY            = "${200 - count.index}"
    SERVER_COUNT        = "${count.index}"
    VIP                 = "${hcloud_floating_ip.lb_vip.ip_address}"
  }
}

data "template_file" "haproxy_template" {
  template = file("${path.module}/templates/haproxy.tpl")
  vars = {
    VIP = "${hcloud_floating_ip.lb_vip.ip_address}"
  }
}

data "template_file" "lb_template" {
  count    = 2
  template = file("${path.module}/templates/lb.tpl")
  vars = {
    HAPROXY_CFG        = base64encode(data.template_file.haproxy_template.rendered)
    KEEPALIVED_CONF    = base64encode(data.template_file.keepalived_template[count.index].rendered)
    KEEPALIVED_SERVICE = base64encode(file("${path.module}/write_files/keepalived.service"))
    MASTER_SCRIPT      = base64encode(file("${path.module}/write_files/master.sh"))
  }
}

data "cloudinit_config" "lb_user_data" {
  gzip          = false
  base64_encode = false
  count         = 2

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.standard_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.lb_template[count.index].rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.lb_vip_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

resource "hcloud_server" "lb" {
  count       = 2
  name        = "lb-${count.index}"
  server_type = var.lb_type
  image       = var.lb_image
  location    = var.location
  user_data   = data.cloudinit_config.lb_user_data[count.index].rendered
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = hcloud_floating_ip.lb_vip.id
  server_id      = hcloud_server.lb[0].id
}
