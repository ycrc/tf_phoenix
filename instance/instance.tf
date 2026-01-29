resource "openstack_compute_instance_v2" "vm" {
  provider        = openstack.phoenix
  name            = "${var.is_test ? "TEST" : "INFRA"}_${var.fqdn}"
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = var.key_pair
  user_data       = data.cloudinit_config.user_data.rendered
  security_groups = var.security_groups

  network {
    name        = var.network
    fixed_ip_v4 = var.ip_address
  }
}
