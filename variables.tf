variable "hcloud_token" {
}

variable "location" {
  description = "Hetzner Region: nbg1, fsn1, or hel1 "
  default     = "fsn1"
}

variable "lb_image" {
  description = "Hetzner OS Image(Currently supported: ubuntu-20.04)"
  default     = "ubuntu-20.04"
}

variable "lb_type" {
  description = "Types can be found here: https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "master_count" {
  description = "Number of kubernetes master servers(must be odd number typically 3)"
  default     = "3"
}

variable "master_image" {
  description = "Hetzner OS Image(Currently supported: ubuntu-20.04)"
  default     = "ubuntu-20.04"
}

variable "master_type" {
  description = "Types can be found here: https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "worker_count" {
  description = "Number of kubernetes worker nodes"
  default     = "1"
}

variable "worker_image" {
  description = "Hetzner OS Image(Currently supported: ubuntu-20.04)"
  default     = "ubuntu-20.04"
}

variable "worker_type" {
  description = "Types can be found here: https://www.hetzner.de/cloud"
  default     = "cx21"
}

variable "ssh_private_key" {
  description = "SSH Private Key to authenticate"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  description = "SSH Public Key to authenticate"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "crio_version" {
  description = "Version of crio to use(1.17 is latest for Ubuntu)"
  default     = "1.17"
}

variable "kubernetes_version" {
  description = "kubernetes version to use"
  default     = "1.18.3"
}

variable "feature_gates" {
  description = "Add Feature Gates e.g. 'DynamicKubeletConfig=true'"
  default     = ""
}

variable "floating_ips" {
  description = "Number of floating IPs to be created"
  default     = "1"
}

