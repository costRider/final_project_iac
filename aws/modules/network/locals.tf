# This file declares calculated local values used across the network module.

locals {
  region_code = coalesce(
    var.region_code,
     replace(var.aws_region, "-", "")
  )

  name_prefix = "${var.project_name}-${var.environment}-aws-${local.region_code}"

  az_code_map = { for az in var.azs : az => replace(az, var.aws_region, local.region_code) }
}
