# This file manages NAT gateway resources for the shared network module.

resource "aws_eip" "nat" {
  count  = length(var.azs)
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-eip-nat-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })
}

resource "aws_nat_gateway" "this" {
  count = length(var.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-nat-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })

  depends_on = [aws_internet_gateway.this]
}
