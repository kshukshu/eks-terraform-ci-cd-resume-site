# IAM
resource "aws_iam_user" "infra_admin" {
  name = "infra-admin"
}

resource "aws_iam_user_policy_attachment" "infra_admin_attach" {
  user       = aws_iam_user.infra_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "infra_admin_key" {
  user = aws_iam_user.infra_admin.name
}

resource "aws_iam_role" "infra_admin_role" {
  name = "infra-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = aws_iam_user.infra_admin.arn
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
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


# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "resume-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = false
  single_nat_gateway = false

  map_public_ip_on_launch = true

  tags = {
    "Project" = "cloud-resume"
  }
}