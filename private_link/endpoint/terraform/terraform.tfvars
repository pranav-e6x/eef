aws_region="us-east-1"
cost_tags = {
  App = "e6data"
  Environment = "Dev"
  Team = "PLT"
  Operation = "PLT-QA"
  User = "plat@e6x.io"
}

vpc_id              = "vpc-03b5f6f73fb2b5897"
subnet_ids          = ["subnet-02a549a0f37960bf4","subnet-07d1e8f6df52b05b9"]
service_name        = "com.amazonaws.vpce.us-east-1.vpce-svc-047ee17cf5ab6a4ce"
