# This file configures security groups and rules for the shared network module.

resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-net-sg-bastion-01"
  description = "Bastion SSH"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow SSH From MyIP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-sg-bastion-01"
  })
}

resource "aws_security_group" "mgmt" {
  name        = "${local.name_prefix}-mgmt-sg-control-01"
  description = "SSH From bastion to MGMT"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow SSH from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-mgmt-sg-control-01"
  })
}

resource "aws_security_group" "node" {
  name        = "${local.name_prefix}-app-sg-node-01"
  description = "Private node security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow all inbound traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-app-sg-node-01"
  })
}
