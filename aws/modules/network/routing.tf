# This file defines routing tables and associations for the shared network module.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-rtb-pub-01"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(var.common_tags, {
    Name = format("%s-%s-net-rtb-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
  })
}

resource "aws_route_table_association" "mgmt" {
  count = length(aws_subnet.mgmt)

  subnet_id      = aws_subnet.mgmt[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "worker" {
  count = length(aws_subnet.worker)

  subnet_id      = aws_subnet.worker[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
