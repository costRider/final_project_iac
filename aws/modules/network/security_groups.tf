# This file configures security groups and rules for the shared network module.

resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-net-sg-bastion-01"
  description = "Bastion SSH"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-sg-bastion-01"
  })
}

resource "aws_security_group" "mgmt" {
  name        = "${local.name_prefix}-mgmt-sg-control-01"
  description = "SSH From bastion to MGMT"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-mgmt-sg-control-01"
  })
}

resource "aws_security_group" "node" {
  name        = "${local.name_prefix}-app-sg-node-01"
  description = "Private node security group"
  vpc_id      = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-app-sg-node-01"
  })
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  description       = "Allow SSH From MyIP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip_cidr]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "mgmt_ingress_ssh_from_bastion" {
  type                     = "ingress"
  description              = "Allow SSH from bastion SG"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.mgmt.id
}

resource "aws_security_group_rule" "mgmt_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mgmt.id
}

resource "aws_security_group_rule" "node_ingress_all_from_vpc" {
  type              = "ingress"
  description       = "Allow all inbound traffic from VPC"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
}
