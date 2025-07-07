# locals {
#   subnet_calc_01 = try([for cidr_block in cidrsubnets(var.vpc_cidr_01, 1, 1) : cidrsubnets(cidr_block, 2, 2, 2, 7)], [])
# }


module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 11.1"

    project_id   = "${var.project_id}"
    network_name = var.environment
    routing_mode = "GLOBAL"

    subnets = [for subnet in local.subnets["private"] :
      {
        subnet_name   = "${var.environment}-${index(local.subnets["private"], subnet)}"
        subnet_ip     = subnet
        subnet_region = var.region
        subnet_private_access = index(local.subnets["private"], subnet) == 2 ? "false" : "true"
        purpose               = index(local.subnets["private"], subnet) == 2 ? "INTERNAL_HTTPS_LOAD_BALANCER" : "PRIVATE"
        role                  = index(local.subnets["private"], subnet) == 2 ? "ACTIVE" : null
      }
    ]

    # secondary_ranges = {
    #     "${var.environment}-subnet-0" = [
    #         for subnet in local.subnets["secondary_ranges"] : { range_name = "${var.environment}-${index(local.subnets["secondary_ranges"], subnet)}", ip_cidr_range = subnet}
    #     ]
    # }
    secondary_ranges = {
        tutorial-0 = [
            {
                range_name    = "${var.environment}-0"
                ip_cidr_range = local.subnets["secondary_ranges"][0]
            },
        ],
        tutorial-1 = [
            {
                range_name    = "${var.environment}-1"
                ip_cidr_range = local.subnets["secondary_ranges"][1]
            },
        ],

    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 7.1"

  name    = "${var.environment}"
  region  = "${var.region}"


  project = "${var.project_id}"
  network = module.vpc.network_name

   nats = [{
     name = "${var.environment}"
   }]
}

resource "google_dns_policy" "default" {
  count = var.enable_dns_policy ? 1 : 0
  name = var.environment
  project = var.project_id
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = module.vpc.network_id
  }
}