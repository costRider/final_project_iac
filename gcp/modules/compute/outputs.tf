output "bastion_external_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "mgmt_internal_ip" {
  value = google_compute_instance.mgmt.network_interface[0].network_ip
}