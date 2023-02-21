resource "aws_network_interface" "dc1_server" {
  subnet_id   = "${element(module.vpc.public_subnets, 0)}"
  security_groups       = [aws_security_group.consul-vm-test.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dc1_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
 # vpc_security_group_ids = [aws_security_group.consul-vm-test.id]

  network_interface {
    network_interface_id = aws_network_interface.dc1_server.id
    device_index         = 0
  }

  launch_template {
     id = aws_launch_template.dc1_server.id
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "server-dc1"
    Owner = "nwales"
    Purpose = "Consul peering Testing"
    se_region = "AMER"
    consul_server_dc1 = "true"
  }
}

resource "aws_launch_template" "dc1_server" {
  name = "dc1_server"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  user_data = filebase64("${path.module}/templates/userdata_dc1_server.sh")

  update_default_version = true
}


### Client

resource "aws_network_interface" "dc1_client" {
  subnet_id   = "${element(module.vpc.public_subnets, 0)}"
  security_groups       = [aws_security_group.consul-vm-test.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dc1_client" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
 # vpc_security_group_ids = [aws_security_group.consul-vm-test.id]

  network_interface {
    network_interface_id = aws_network_interface.dc1_client.id
    device_index         = 0
  }

  launch_template {
     id = aws_launch_template.dc1_client.id
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "client-dc1"
    Owner = "nwales"
    Purpose = "Consul peering Testing"
    se_region = "AMER"
  }
}

resource "aws_launch_template" "dc1_client" {
  name = "dc1_client"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  user_data = filebase64("${path.module}/templates/userdata_dc1_client.sh")

  update_default_version = true
}