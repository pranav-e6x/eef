aws_region="us-east-1"
cost_tags = {
  App = "e6data"
  Environment = "Dev"
  Team = "PLT"
  Operation = "PLT-QA"
  User = "plat@e6x.io"
}

vpc_id              = "vpc-0241483f7a3de0cb9"
subnet_ids          = ["subnet-02dae3e2989b090fb","subnet-0ae931ec24fa50a74"]
eks_cluster_name    = "privatelinktest"