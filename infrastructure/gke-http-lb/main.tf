
# Networking
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.1"

  project_id              = var.project_id
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
  subnets                 = var.subnets
  secondary_ranges        = var.secondary_ranges
  ingress_rules           = var.ingress_rules
  egress_rules            = var.egress_rules
}

# GKE
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version                    = "~> 31.1"
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  regional                   = var.regional
  zones                      = var.zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  http_load_balancing        = var.http_load_balancing
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  enable_private_endpoint    = var.enable_private_endpoint
  enable_private_nodes       = var.enable_private_nodes
  dns_cache                  = var.dns_cache
  deletion_protection        = var.deletion_protection
  allow_net_admin            = var.allow_net_admin
}

# GIP
resource "google_compute_global_address" "global_external_ip" {
  count        = var.create_global_external_ip ? 1 : 0
  project      = var.project_id
  name         = "global-external-ip"
  address_type = "EXTERNAL"
}

# SSL policy
resource "google_compute_ssl_policy" "ssl_policy" {
  count   = var.ssl_policy_enabled ? 1 : 0
  project = var.project_id
  name    = "ssl-policy"
  profile         = var.ssl_profile
  min_tls_version = var.ssl_min_tls_version
}

# Cloud Armor Policy
resource "google_compute_security_policy" "cloud_armor_policy" {
  count   = var.cloud_armor_enabled ? 1 : 0
  name    = "cloud-armor-policy"
  project = var.project_id

  dynamic "rule" {
    for_each = length(var.cloud_armor_allowed_ips) == 0 ? [] : [1]

    content {
      action   = "allow"
      priority = "999"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.cloud_armor_allowed_ips
        }
      }
      description = "Allow list of IPs"
    }
  }

  dynamic "rule" {
    for_each = length(var.cloud_armor_rules) > 0 ? var.cloud_armor_rules : {}

    content {
      action   = rule.value.action
      priority = rule.value.priority
      match {
        expr {
          expression = rule.value.expression
        }
      }
      description = rule.value.description
      preview     = rule.value.preview

    }
  }

  dynamic "rule" {
    for_each = length(var.cloud_armor_denied_ips) == 0 ? [] : [1]

    content {
      action   = "deny(403)"
      priority = "990"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.cloud_armor_denied_ips
        }
      }
      description = "Deny list of IPs"
    }
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

  dynamic "adaptive_protection_config" {
    for_each = var.cloud_armor_adaptive_protection ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = "STANDARD"
      }
    }
  }
}
