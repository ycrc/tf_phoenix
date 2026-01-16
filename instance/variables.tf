variable "fqdn" {
  type        = string
  description = "Fully Qualified Domain Name"
}

variable "is_test" {
  type        = bool
  description = "Deployment is for testing"
  default     = false
}

variable "flavor" {
  type        = string
  description = "Machine configuration to use for virtual machine"
  default     = "2/4/20"
}

variable "image" {
  type        = string
  description = "Image to use for virtual machine"
  default     = "rhel-8.10"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups for the virtual machine"
  default     = ["default"]
}

variable "username" {
  type        = string
  description = "Username for the default user"
  default     = "ansible"
}

variable "key_pair" {
  type        = string
  description = "SSH public key to install for the default user"
  default     = null
}

variable "network" {
  type        = string
  description = "Network to use for virtual machine"
  default     = "Yale-VL20"
}

variable "ip_address" {
  type        = string
  description = "IP Address to use for virtual machine"
  default     = null
}

variable "ssh_host_keys" {
  type        = map(string)
  description = "Map of ssh host keys with entries like {<key type>_private => <file content>}"
  default     = null
}
