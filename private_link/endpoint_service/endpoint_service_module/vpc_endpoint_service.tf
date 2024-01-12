resource "aws_vpc_endpoint_service" "eks_endpoint_service" {
  acceptance_required        = false
  allowed_principals         = var.allowed_principals
  supported_ip_address_types = ["ipv4"]
  network_load_balancer_arns = [aws_lb.eks_nlb.arn]
}