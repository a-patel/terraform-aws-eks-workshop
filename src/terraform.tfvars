aws_access_key = ""
aws_secret_key = ""

region                   = "us-west-2"
availability_zones_count = 2

project = "TFEKSWorkshop"

# vpc
vpc_cidr         = "10.0.0.0/16"
subnet_cidr_bits = 8

# cluster
k8s_service_cidr = "192.168.0.0/16"

# sg and nacl
office_cidr = "0.0.0.0/0"
