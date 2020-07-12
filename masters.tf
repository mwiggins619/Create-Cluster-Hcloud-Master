data "template_file" "crio_template" {
  template = file("${path.module}/templates/crio.tpl")
  vars = {
    CRIO_VERSION = var.crio_version
    OS_NAME      = title(regex("[[:alpha:]]+", var.master_image))
    VERSION_ID   = regex("[[:digit:]].*", var.master_image)
  }
}

data "template_file" "k8s_template" {
  template = file("${path.module}/templates/k8s.tpl")
  vars = {
    CGROUPS_CONF        = base64encode(file("${path.module}/write_files/11-cgroups.conf"))
    HCLOUD_CONF         = base64encode(file("${path.module}/write_files/20-hcloud.conf"))
    KUBERNETES_CRI_CONF = base64encode(file("${path.module}/write_files/99-kubernetes-cri.conf"))
    KUBERNETES_VERSION  = var.kubernetes_version
  }
}

data "template_file" "kubeadm_init_template" {
  template = file("${path.module}/templates/kubeadm_init.tpl")
  vars = {
    FEATURE_GATES      = var.feature_gates
    KUBERNETES_VERSION = var.kubernetes_version
    VIP                = hcloud_floating_ip.lb_vip.ip_address
  }
}

data "template_file" "kubeadm_sh" {
  template = file("${path.module}/templates/kubeadm_init_master_0.tpl")
  vars = {
    FEATURE_GATES = var.feature_gates
    HCLOUD_TOKEN  = var.hcloud_token
    NETWORK_ID    = hcloud_network.k8s.id
  }
}

data "template_file" "k8s_master_0" {
  template = file("${path.module}/templates/k8s_master_0.tpl")
  vars = {
    APISERVER_AUDIT_POLICY = base64encode(file("${path.module}/write_files/apiserver-audit-policy.yaml"))
    KUBEADM_INIT           = base64encode(data.template_file.kubeadm_init_template.rendered)
    KUBEADM_SH             = base64encode(data.template_file.kubeadm_sh.rendered)
  }
}

data "cloudinit_config" "master_0_user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.standard_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.crio_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.k8s_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.k8s_master_0.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

}

resource "hcloud_server" "master_0" {
  name        = "master-0"
  server_type = var.master_type
  image       = var.master_image
  location    = var.location
  user_data   = data.cloudinit_config.master_0_user_data.rendered

  provisioner "local-exec" {
    command = "bash scripts/copy-kubeadm-token.sh"
    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME    = "sre"
      SSH_HOST        = hcloud_server.master_0.ipv4_address
      TARGET          = "${path.module}/out/"
    }
  }
}

data "local_file" "kubeadm_join" {
  filename = "${path.module}/out/kubeadm_join"
  depends_on = [
    hcloud_server.master_0
  ]
}

data "template_file" "kubeadm_join_master" {
  count    = var.master_count - 1
  template = file("${path.module}/templates/kubeadm_join_master.tpl")
  vars = {
    APISERVER_AUDIT_POLICY = base64encode(file("${path.module}/write_files/apiserver-audit-policy.yaml"))
    HCLOUD_TOKEN    = var.hcloud_token
    KUBEADM_JOIN    = data.local_file.kubeadm_join.content_base64
    NETWORK_ID      = hcloud_network.k8s.id
    PRIVATE_IP      = "192.168.0.${count.index + 3}"
    SERVER_NAME     = "master-${count.index + 1}"
  }
}

data "cloudinit_config" "other_masters_user_data" {
  gzip          = false
  base64_encode = false
  count         = var.master_count - 1

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.standard_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.crio_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.k8s_template.rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.kubeadm_join_master[count.index].rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

resource "hcloud_server" "other_masters" {
  count       = var.master_count - 1
  name        = "master-${count.index + 1}"
  server_type = var.master_type
  image       = var.master_image
  location    = var.location
  user_data   = data.cloudinit_config.other_masters_user_data[count.index].rendered
  depends_on = [
    hcloud_server.master_0
  ]
}

