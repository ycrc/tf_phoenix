resource "ansible_host" "vm" {
  name = openstack_compute_instance_v2.vm.name

  variables = {
    ansible_user = var.username,
    ansible_host = openstack_compute_instance_v2.vm.access_ip_v4,
  }
}
