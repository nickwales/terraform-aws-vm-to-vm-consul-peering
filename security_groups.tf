resource "aws_security_group" "consul-vm-test" {
  name_prefix = "consul-vm-test"
  description = "Allow all traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Full Access"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    // cidr_blocks      = [aws_vpc.main.cidr_block]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}