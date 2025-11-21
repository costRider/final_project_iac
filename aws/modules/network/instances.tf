# This file provisions bastion and management instances within the network module.

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id
  instance_type               = var.instance_type_bastion
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-net-bastion-01"
  })
}

resource "aws_instance" "mgmt" {
  ami                    = var.mgmt_ami_id
  instance_type          = var.instance_type_mgmt
  subnet_id              = aws_subnet.mgmt[0].id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.mgmt.id]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-mgmt-admin-01"
  })
}
