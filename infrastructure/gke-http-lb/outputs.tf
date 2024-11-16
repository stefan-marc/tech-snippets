output "global_external_ip_address" {
  value = var.create_global_external_ip ? google_compute_global_address.global_external_ip[0].address : null
}
