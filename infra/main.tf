# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "resume-vpc"
  cidr = "10.0.0.0/16"

  azs                     = ["eu-central-1a", "eu-central-1b"]
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway      = false
  single_nat_gateway      = false
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    "Project" = "cloud-resume"
  }
}

# VPC Endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.vpc.default_security_group_id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.eu-central-1.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.vpc.default_security_group_id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.eu-central-1.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.vpc.default_security_group_id]
}

# EKS
resource "aws_eks_cluster" "resume_cluster" {
  name     = "resume-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }

  depends_on = [
    aws_iam_role.eks_cluster,
    aws_iam_role.infra_admin_role
  ]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.resume_cluster.name
  node_group_name = "default-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_eks_cluster.resume_cluster
  ]
}

