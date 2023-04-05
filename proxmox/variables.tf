# Proxmox variables

variable "pm_api_url" {
  default = "https://10.0.0.99:8006/api2/json"
}

variable "pm_user" {
  default = "root@pam"
}

variable "pm_tls_insecure" {
  default = true
}

variable "pm_password" {
  sensitive = true
}

variable "target_node" {
  default = "lowtower"
}

# VM variables

variable "small" { 
    default = [
	"kubernetes-master-1" 
]
}

variable "medium" {
    default = [
        "kubernetes-worker-1", "kubernetes-worker-2", "kubernetes-worker-3"
]
}


variable "specs" {
  type = map
  default = {
  "templateName" = "CentosTemplate"
  "small-memory" = "4096"
  "small-cpu" = "4"
  "small-disk" = "32G"
  "small-sockets" = "1"
  "medium-memory" = "16384"
  "medium-cpu" = "4"
  "medium-disk" = "32G"
  "medium-sockets" = "1"
    }
  }
