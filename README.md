# Terraform Kubernetes on Hetzner Cloud
#Hcloud

This repository will help to setup a crio based Kubernetes Cluster with [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) on [Hetzner Cloud](https://www.hetzner.com/cloud?country=us).

## Usage

```
$ git clone
$ terraform init
$ terraform apply
```

## Example

```
$ terraform init
$ terraform apply
$ KUBECONFIG=out/config kubectl get nodes
$ KUBECONFIG=out/config kubectl get pods --namespace=kube-system -o wide
$ KUBECONFIG=out/config kubectl run nginx --image=nginx
$ KUBECONFIG=out/config kubectl expose deploy nginx --port=80 --type NodePort
```

## Variables

|  Name                    |  Default     |  Description                                                                      | Required |
|:-------------------------|:-------------|:----------------------------------------------------------------------------------|:--------:|
| `hcloud_token`        | ``                      | API Token for your hetzner cloud project https://console.hetzner.cloud/projects               | Yes |
| `master_count`        | `3`                     | Number of masters to be created. Must be odd number.                                          | Yes |
| `master_image`        | `ubuntu-20.04`          | Hetzner OS Image(Currently supported: ubuntu-20.04)                                           | No  |
| `master_type`         | `cx21`                  | Types can be found here:  https://www.hetzner.de/cloud                                        | No  |
| `node_count`          | `1`                     | Amount of nodes that will be created                                                          | No  |
| `node_image`          | `ubuntu-20.04`          | Hetzner OS Image(Currently supported: ubuntu-20.04)                                           | No  |
| `node_type`           | `cx21`                  | Types can be found here: https://www.hetzner.de/cloud                                         | No  |
| `ssh_private_key`     | `~/.ssh/id_ed25519`     | SSH Private Key to authenticate                                                               | No  |
| `ssh_public_key`      | `~/.ssh/id_ed25519.pub` | SSH Public Key to authenticate                                                                | No  |
| `crio_version`        | `1.17`                  | crio version that will be used                                                                | No  |
| `kubernetes_version`  | `1.18.3`                | Kubernetes version to use                                                                     | No  |
| `feature_gates`       | ``                      | Add Feature Gates for Kubeadm                                                                 | No  |
| `calico_enabled`      | `true`                  | Installs Calico Network Provider after the master comes up                                    | No  |
| `floating_ips`        | ``                      | Number of floating IPs to be created                                                          | No  |

All variables cloud be passed through `environment variables` or a `tfvars` file.

An example for a `tfvars` file would be the following `terraform.tfvars`

```toml
# terraform.tfvars
hcloud_token = "$APITOKEN"
master_type = "cx21"
master_count = 3
node_type = "cx31"
node_count = 2
kubernetes_version = "1.18.3"
crio_version = "1.17"
```

Or passing directly via Arguments

```console
$ terraform apply \
  -var hcloud_token="$APITOKEN" \
  -var crio_version=1.17 \
  -var kubernetes_version=1.18.3 \
  -var master_type=cx21 \
  -var master_count=3 \
  -var node_type=cx31 \
  -var node_count=2
```

## Tools Used

- Terraform [v0.12.26](https://github.com/hashicorp/terraform/tree/v0.12.26)
- provider.hcloud [v1.19.0](https://github.com/terraform-providers/terraform-provider-hcloud)
- hcloud-cloud-controller-manager [v1.6.1](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/master/docs/deploy_with_networks.md)
- hcloud-csi-driver [v1.4.0](https://github.com/hetznercloud/csi-driver)
