# Common data
variable "project_id" {
  description = "The project ID to deploy the GKE cluster"
  type        = string
}

# Network
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode"
  type        = string
  default     = "GLOBAL"
}

variable "auto_create_subnetworks" {
  description = "Create subnetworks automatically"
  type        = bool
  default     = false
}

variable "subnets" {
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = string
    subnet_private_access            = optional(string)
    subnet_private_ipv6_access       = optional(string)
    subnet_flow_logs                 = optional(string)
    subnet_flow_logs_interval        = optional(string)
    subnet_flow_logs_sampling        = optional(string)
    subnet_flow_logs_metadata        = optional(string)
    subnet_flow_logs_filter          = optional(string)
    subnet_flow_logs_metadata_fields = optional(list(string))
    description                      = optional(string)
    purpose                          = optional(string)
    role                             = optional(string)
    stack_type                       = optional(string)
    ipv6_access_type                 = optional(string)
  }))
  description = "The list of subnets being created"
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}

variable "ingress_rules" {
  description = "List of ingress rules"
  default     = []
  type = list(object({
    name                    = string
    description             = optional(string, null)
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    log_config = optional(object({
      metadata = string
    }))
  }))
}

variable "egress_rules" {
  description = "List of egress rules"
  default     = []
  type = list(object({
    name                    = string
    description             = optional(string, null)
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    log_config = optional(object({
      metadata = string
    }))
  }))
}

# GKE
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "regional" {
  description = "Create a regional cluster"
  type        = bool
  default     = false

}

variable "region" {
  description = "The region to host the cluster in (optional if zonal cluster / required if regional)"
  default     = null
  type        = string
}

variable "zones" {
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = []
  type        = list(string)
}

variable "ip_range_pods" {
  description = "The IP range for the pods"
  type        = string
}

variable "ip_range_services" {
  description = "The IP range for the services"
  type        = string
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancing"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling"
  type        = bool
  default     = true
}

variable "filestore_csi_driver" {
  description = "Enable the Filestore CSI driver"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  default     = true
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = false
}

variable "dns_cache" {
  description = "Enable DNS cache"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Whether or not to allow Terraform to destroy the cluster."
  default     = false
}

variable "allow_net_admin" {
  type = bool
  description = "Whether to enable the network admin role for the default service account"
  default = true
}

# GIP
variable "create_global_external_ip" {
  description = "Create a global external IP"
  type        = bool
  default     = false
}

# SSL Policy
variable "ssl_policy_enabled" {
  description = "Enable SSL Policy"
  type        = bool
  default     = false
}

variable "ssl_profile" {
  description = "The profile of the SSL policy"
  type        = string
  default     = "MODERN"
  
}

variable "ssl_min_tls_version" {
  description = "The minimum TLS version of the SSL policy"
  type        = string
  default     = "TLS_1_2"
}

# Cloud Armor
variable "cloud_armor_enabled" {
  description = "Enable Cloud Armor"
  type        = bool
  default     = false
}

variable "cloud_armor_allowed_ips" {
  description = "List of allowed IPs"
  type        = list(string)
  default     = []
}

variable "cloud_armor_rules_enabled" {
  description = "Enable Cloud Armor rules"
  type        = bool
  default     = false
}

variable "cloud_armor_rules" {
  description = "List of rules to apply to CloudArmor. Default: {}"
  type = map(object({
    action      = string
    priority    = string
    expression  = string
    description = string
    preview     = bool
  }))
  default = {}
}

variable "cloud_armor_denied_ips" {
  description = "List of denied IPs"
  type        = list(string)
  default     = []
}

variable "cloud_armor_adaptive_protection" {
  description = "Enable CloudArmor Adaptive Protection DDoS."
  type        = bool
  default     = false
}
