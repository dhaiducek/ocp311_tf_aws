# Define and query for the RHEL 7.7 AMI
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat's account ID
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["RHEL-7.7*GA*"]
  }
}

# Create Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = "t2.small"
  iam_instance_profile        = aws_iam_instance_profile.ocp311_master_profile.id
  key_name                    = aws_key_pair.default.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.ocp311_ssh.id,
    aws_security_group.ocp311_vpc.id,
    aws_security_group.ocp311_public_egress.id
  ]

  user_data = data.template_file.cloud-init.rendered

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-bastion"
    })
  )

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    content     = data.template_file.inventory.rendered
    destination = "~/inventory.yaml"
  }

  provisioner "file" {
    content     = file(var.ssh_private_key_path)
    destination = "~/.ssh/id_rsa"
  }
}

# Create Master EC2 instance
resource "aws_instance" "master" {
  ami                  = data.aws_ami.rhel.id
  instance_type        = "m4.xlarge"
  iam_instance_profile = aws_iam_instance_profile.ocp311_master_profile.id
  key_name             = aws_key_pair.default.key_name
  subnet_id            = aws_subnet.private_subnet.id
  vpc_security_group_ids = [
    aws_security_group.ocp311_vpc.id,
    aws_security_group.ocp311_public_ingress.id,
    aws_security_group.ocp311_public_egress.id
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
  ebs_block_device {
    volume_type = "gp2"
    device_name = "/dev/sdf"
    volume_size = 80
  }

  user_data = data.template_file.cloud-init.rendered

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-master"
    })
  )
}

# Create Node EC2 instance
resource "aws_instance" "node" {
  ami                  = data.aws_ami.rhel.id
  instance_type        = "m4.large"
  iam_instance_profile = aws_iam_instance_profile.ocp311_worker_profile.id
  key_name             = aws_key_pair.default.key_name
  subnet_id            = aws_subnet.private_subnet.id
  vpc_security_group_ids = [
    aws_security_group.ocp311_vpc.id,
    aws_security_group.ocp311_public_ingress.id,
    aws_security_group.ocp311_public_egress.id
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
  ebs_block_device {
    volume_type = "gp2"
    device_name = "/dev/sdf"
    volume_size = 80
  }

  user_data = data.template_file.cloud-init.rendered

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-node"
    })
  )
}
