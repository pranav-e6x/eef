variable "aws_region" {
  type       = string
  description = "AWS region"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "service_name" {
  type = string
}

variable "cost_tags" {
  type = map(string)
  description = "cost tags"
}
