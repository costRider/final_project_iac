locals {
  region_code = coalesce(
    var.region_code,
    replace(regexreplace(var.aws_region, "(ap)-(northeast)-(\d)", "$1-$2-$3"), "ap-northeast-", "apne")
  )

  name_prefix = "${var.project_name}-${var.environment}-aws-${local.region_code}"

  az_code_map = { for az in var.azs : az => replace(az, var.aws_region, local.region_code) }
}
