module "eks_private_link" {
  source              = "./endpoint_service_module"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids

  eks_cluster_name    = var.eks_cluster_name
}

data "aws_subnet" "avl_zones" {
  count = length(var.subnet_ids)

  id = var.subnet_ids[count.index]
}
