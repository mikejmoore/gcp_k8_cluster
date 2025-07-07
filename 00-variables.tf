variable "project_id" {
  default = "tutorial-1-218017"
}

variable "environment" {
  default = "tutorial"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "zones" {
  type = list(string)
  default = ["us-central1-a", "us-central1-b", "us-central1-f"]
}

variable "region" {
  default = "us-central1"
}

variable "enable_dns_policy" {
  type = bool
  default = true
}

variable "project_service_account" {
  default = "tutorial@tutorial-1-218017.iam.gserviceaccount.com"
}

variable "network_policy_gke" {
  type = bool
  default = false
}

variable "node_configs" {
  default = [
    {
      type = "e2-small"
      spot = true
      min = 1
      max = 3
      initial_node_count = 1
      enable_secure_boot = true
      disk_size_gb = 10
    }
  ]
}

locals {
  subnets_calc = [for cidr_block in cidrsubnets(var.vpc_cidr, 1, 1) : cidrsubnets(cidr_block, 2, 2, 2, 2)]
  private_subnets =  slice(local.subnets_calc[0], 0, 3)

  subnets = {
    private       = slice(local.subnets_calc[0], 0, 3)
    secondary_ranges = concat(local.subnets_calc[1], slice(local.subnets_calc[0], 3, 4))
  }
}


