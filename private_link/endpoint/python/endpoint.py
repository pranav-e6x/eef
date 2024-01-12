import boto3

# AWS credentials setup (replace with your own credentials or use environment variables)
aws_access_key = "<>"
aws_secret_key = "<>"
aws_session_token = "<>"
region_name = "<>"

# Create a Boto3 session
session = boto3.Session(
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key,
    aws_session_token=aws_session_token,
    region_name=region_name,
)

# Create a Boto3 client for the EC2 service
ec2_client = session.client("ec2")

# Define the VPC ID, service name of the endpoint service and securitygroup id for the endpoint
vpc_id = "vpc-abcdefghig"
servicename = "com.amazonaws.vpce.<region>.vpce-svc-abcdehbjb"
securitygroup_id = "sg-abcdef"

# Define tags as a map of strings
tags = {
    "Name": "MyEndpoint",
    "Environment": "Production"
}

# Retrieve all private subnets with type=private tag
subnets_response = ec2_client.describe_subnets(
    Filters=[
        {"Name": "vpc-id", "Values": [vpc_id]},
        {"Name": "tag:type", "Values": ["private"]},
    ]
)
private_subnets = subnets_response["Subnets"]

# Check if there are available private subnets to create the VPC endpoint
if not private_subnets:
    print("No private subnets found with the 'type=private' tag.")
else:
    endpoint_created = False

    for subnet in private_subnets:
        subnet_id = subnet["SubnetId"]

        try:
            response = ec2_client.create_vpc_endpoint(
                VpcId=vpc_id,
                ServiceName=servicename,
                VpcEndpointType="Interface",
                SecurityGroupIds=[securitygroup_id],
                SubnetIds=[subnet_id],
                TagSpecifications=[
                    {
                        "ResourceType": "vpc-endpoint",
                        "Tags": [{"Key": key, "Value": value} for key, value in tags.items()]
                    }
                ]
            )

            print("VPC Endpoint Created:")
            print(response)
            endpoint_created = True
            break  # Break the loop if endpoint creation is successful
        except Exception as e:
            print(f"Error creating VPC endpoint with subnet {subnet_id}: {str(e)}")

    if not endpoint_created:
        print("Could not create VPC endpoint with any of the available subnets.")
