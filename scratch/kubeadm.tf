resource "random_string" "part_one" {
  length  = 6
  special = false
}

resource "random_string" "part_two" {
  length  = 16
  special = false
}

data "template_file" "kubeadm_token"{
  template = file("${path.module}/templates/kubeadm_token.tpl")
  vars = {
    PART_ONE =  resource.random_string.part_one.result
    PART_TWO =  resource.random_string.part_two.result
  }
}

resource "random_string" "certificate_key" {
  length   = 64
  is_upper = false
  special  = false
  
}

