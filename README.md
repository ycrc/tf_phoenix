# tf_phoenix

Terraform modules for provisioning infrastructure on the Yale [Phoenix](https://docs.ycrc.yale.edu/) OpenStack
cloud, with opinionated defaults for YCRC deployments.

The repository currently contains a single module:

| Module | Description |
| ------ | ----------- |
| [`instance/`](instance/) | An OpenStack VM, seeded with cloud-init and registered into an Ansible inventory. |

## The `instance` module

`instance` wraps the three things needed to stand up a manageable VM so that a caller only has to supply a
hostname:

1. **`openstack_compute_instance_v2.vm`** — the virtual machine itself, attached to a single network with an
   optional fixed IPv4 address.
2. **`data.cloudinit_config.user_data`** — a `#cloud-config` part that sets the hostname/FQDN, creates the
   default user, forces the `America/New_York` timezone, disables root login and SSH password authentication,
   and optionally installs persistent SSH host keys.
3. **`ansible_host.vm`** — an entry for the `ansible/ansible` provider so the new VM shows up in a generated
   Ansible inventory with `ansible_user` and `ansible_host` already set.

### Requirements

| Name | Version |
| ---- | ------- |
| [terraform-provider-openstack/openstack](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest) | `>= 3.4.0` |
| [hashicorp/cloudinit](https://registry.terraform.io/providers/hashicorp/cloudinit/latest) | `>= 2.3.7` |
| [ansible/ansible](https://registry.terraform.io/providers/ansible/ansible/latest) | `>= 1.3.0` |

The module declares `required_providers` but deliberately contains **no `provider` blocks** — configuration
(and authentication) is inherited from the root module. Configure the OpenStack provider there, typically by
sourcing an application-credential `openrc` file before running Terraform:

```bash
source ~/Phoenix-openrc.sh
terraform init && terraform apply
```

### Usage

Minimal — every other input has a default:

```hcl
module "web" {
  source = "github.com/ycrc/tf_phoenix//instance"

  fqdn = "web01.ycrc.yale.edu"
}
```

More complete:

```hcl
module "web" {
  source = "github.com/ycrc/tf_phoenix//instance"

  fqdn            = "web01.ycrc.yale.edu"
  is_test         = true
  flavor          = "4/8/40"
  image           = "rhel-8.10"
  security_groups = ["default", "web"]
  key_pair        = "ycrc-ops"
  ip_address      = "10.0.20.31"

  ssh_host_keys = {
    ed25519_private = file("${path.module}/keys/web01_ed25519")
    ed25519_public  = file("${path.module}/keys/web01_ed25519.pub")
  }
}
```

### Inputs

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `fqdn` | `string` | _required_ | Fully qualified domain name. Used for the instance name, the cloud-init `hostname`/`fqdn`, and the Ansible inventory entry. |
| `is_test` | `bool` | `false` | Marks the deployment as a test. Controls the instance name prefix and the Ansible group (see [Naming and grouping](#naming-and-grouping)). |
| `flavor` | `string` | `"2/4/20"` | OpenStack flavor name (vCPU/GB RAM/GB disk). |
| `image` | `string` | `"rhel-9.6"` | Name of the Glance image to boot from. |
| `security_groups` | `list(string)` | `["default"]` | Security groups to attach to the instance. |
| `username` | `string` | `"cfgmgt"` | Default user created by cloud-init, and the `ansible_user` in the inventory. |
| `key_pair` | `string` | `null` | Name of an existing OpenStack keypair to install for the default user. |
| `network` | `string` | `"Yale-VL20"` | Name of the network to attach to. |
| `ip_address` | `string` | `null` | Fixed IPv4 address on that network. Leave `null` to let OpenStack assign one. |
| `ssh_host_keys` | `map(string)` | `null` | SSH **host** keys to install, passed through to cloud-init's `ssh_keys`. Keys are named `<type>_private` / `<type>_public` (e.g. `ed25519_private`, `rsa_public`); values are the file contents. |

### Outputs

The module currently defines no outputs. To reach attributes of the created VM, add them to the module (for
example `openstack_compute_instance_v2.vm.access_ip_v4`) rather than reading them from state.

### Naming and grouping

`is_test` drives two conventions at once:

| `is_test` | Instance name | Ansible group |
| --------- | ------------- | ------------- |
| `false` (default) | `INFRA_<fqdn>` | `production` |
| `true` | `TEST_<fqdn>` | `development` |

### Notes

- **Host keys are secrets.** `ssh_host_keys` carries private key material into the Terraform plan and state.
  The variable is not marked `sensitive`, so values may appear in plan output; state files should be treated
  as sensitive and are excluded from version control by [.gitignore](.gitignore) along with `*.tfvars`.
- **Ansible inventory.** The `ansible_host` resources are consumed by the `cloud.terraform` inventory plugin,
  which reads Terraform state to build a live inventory — no static inventory file to maintain.
- **Some changes replace the instance.** `fqdn`, `username`, and `ssh_host_keys` are all baked into
  `user_data`, which forces a new instance — as do `image`, `key_pair`, `network`, and `ip_address`.
  `flavor` triggers an OpenStack resize instead, and `security_groups` and `is_test` (which only affects the
  instance name and the inventory group) update in place.
