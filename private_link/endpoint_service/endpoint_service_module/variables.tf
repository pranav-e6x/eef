variable "vpc_id" {
  type = string
  description = "vpc_id in whcih the eks cluster is present"
}

variable "subnet_ids" {
  type = list(string)
  description = "private subnets in which the eks is present"
}

variable "eks_cluster_name" {
  type = string
}

variable "allowed_principals" {
  type = list(string)
  default = ["arn:aws:iam::298655976287:root"]
}

variable "port" {
  type = number
  default = 443
}