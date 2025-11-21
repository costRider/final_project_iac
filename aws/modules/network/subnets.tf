resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-net-subnet-pub-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  })
}

resource "aws_subnet" "mgmt" {
  count = length(var.private_mgmt_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_mgmt_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-mgmt-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

resource "aws_subnet" "worker" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-app-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

resource "aws_subnet" "db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name                                   = format("%s-%s-db-subnet-prv-%02d", local.name_prefix, local.az_code_map[var.azs[count.index]], count.index + 1)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}
