data "cloudinit_config" "user_data" {
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = <<-EOT
      #cloud-config
      ${yamlencode({
        user                 = var.username
        hostname             = var.fqdn
        fqdn                 = var.fqdn
        timezone             = "America/New_York"
        create_hostname_file = true
        disable_root         = true
        ssh_pwauth           = false
        ssh_keys             = var.ssh_host_keys
      })}
    EOT
  }
}
