resource "aws_network_interface" "dc2_server" {
  subnet_id   = "${element(module.vpc.public_subnets, 0)}"
  security_groups       = [aws_security_group.consul-vm-test.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dc2_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
 # vpc_security_group_ids = [aws_security_group.consul-vm-test.id]

  network_interface {
    network_interface_id = aws_network_interface.dc2_server.id
    device_index         = 0
  }

  launch_template {
     id = aws_launch_template.dc2_server.id
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "server-dc2"
    Owner = "nwales"
    Purpose = "Consul peering Testing"
    se_region = "AMER"
  }
}

resource "aws_launch_template" "dc2_server" {
  name = "dc2_server"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  user_data = filebase64("${path.module}/templates/userdata_dc2_server.sh")

  update_default_version = true
}


### Client

resource "aws_network_interface" "dc2_client" {
  subnet_id   = "${element(module.vpc.public_subnets, 0)}"
  security_groups       = [aws_security_group.consul-vm-test.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dc2_client" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
 # vpc_security_group_ids = [aws_security_group.consul-vm-test.id]

  network_interface {
    network_interface_id = aws_network_interface.dc2_client.id
    device_index         = 0
  }

  launch_template {
     id = aws_launch_template.dc2_client.id
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "client-dc2"
    Owner = "nwales"
    Purpose = "Consul peering Testing"
    se_region = "AMER"
    consul_server_dc1 = "true"
  }
}

resource "aws_launch_template" "dc2_client" {
  name = "dc2_client"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  user_data = filebase64("${path.module}/templates/userdata_dc2_client.sh")

  update_default_version = true
}