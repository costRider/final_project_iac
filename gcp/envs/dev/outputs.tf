output "bastion_external_ip" {
  value = module.compute.bastion_external_ip
}

output "mgmt_internal_ip" {
  value = module.compute.mgmt_internal_ip
}