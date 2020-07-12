data "template_file" "kubeadm_join_worker" {
  count    = var.worker_count
  template = file("${path.module}/templates/kubeadm_join_worker.tpl")
  vars = {
    HCLOUD_TOKEN    = var.hcloud_token
    KUBEADM_JOIN    = data.local_file.kubeadm_join.content_base64
    NETWORK_ID      = hcloud_network.k8s.id
    PRIVATE_IP      = "192.168.0.${count.index + 10}"
    SERVER_NAME     = "worker-${count.index}"
  }
}

data "cloudinit_config" "workers_user_data" {
  gzip          = false
  base64_encode = false
  count         = var.worker_count

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
    content      = data.template_file.kubeadm_join_worker[count.index].rendered
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

resource "hcloud_server" "workers" {
  count       = var.worker_count
  name        = "worker-${count.index}"
  server_type = var.master_type
  image       = var.master_image
  location    = var.location
  user_data   = data.cloudinit_config.workers_user_data[count.index].rendered
  depends_on = [
    hcloud_server.other_masters
  ]
}

