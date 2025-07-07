# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = "${var.environment}-1"
  region                     = var.region
  zones                      = var.zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  # ip_range_pods              = "${module.vpc.subnets_names[0]}"
  # ip_range_services          = "${module.vpc.subnets_names[1]}"
  ip_range_pods              = "tutorial-0"
  ip_range_services          = "tutorial-1"
  http_load_balancing        = true
  network_policy             = var.network_policy_gke
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false

  node_pools = [for each in var.node_configs :
    {
      name                        = "${each.type}-${try(each.index, 0)}"
      machine_type                = each.type
      node_locations              = join(",", var.zones)
      min_count                   = each.min
      max_count                   = each.max
      local_ssd_count             = 0
      spot                        = each.spot
      disk_size_gb                = each.disk_size_gb
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      service_account             = var.project_service_account
      preemptible                 = false
      initial_node_count          = 80
      accelerator_count           = lookup(each, "accelerator_count", 0)
      accelerator_type            = lookup(each, "accelerator_type", "")
      gpu_driver_version          = lookup(each, "gpu_driver_version", "")
      gpu_sharing_strategy        = "TIME_SHARING"
      max_shared_clients_per_gpu = 2
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}