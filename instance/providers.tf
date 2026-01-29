terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = ">= 3.4.0"
      configuration_aliases = [ openstack.phoenix ]
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = ">= 2.3.7"
    }
    ansible = {
      source = "ansible/ansible"
      version = ">= 1.3.0"
    }
  }
}

provider "openstack" {
  alias       = "phoenix"
  auth_url    = "http://controller:5000/v3"
  tenant_name = "YCRC"
}
