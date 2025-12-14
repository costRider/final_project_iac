##################################
#  Network 리소스에서 내보낼 값
##################################

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.this.self_link
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "subnets" {
  description = "Map of created subnets"
  value = {
    for k, v in google_compute_subnetwork.this :
    k => {
      name   = v.name
      region = v.region
      cidr   = v.ip_cidr_range
      self   = v.self_link

      #GKE를 위한 secondary range
       secondary_ranges = [
        for r in v.secondary_ip_range : {
          range_name    = r.range_name
          ip_cidr_range = r.ip_cidr_range
        }
      ]
    }
  }
}
