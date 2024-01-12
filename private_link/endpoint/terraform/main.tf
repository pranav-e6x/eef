resource "aws_vpc_endpoint" "endpoint" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_ids
  security_group_ids = [
    aws_security_group.endpoint_sg.id,
  ]
}

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint_sg"
  description = "Allow endpoint inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
