provider "aws" {
  region  = var.aws_region
  profile = "infra-admin"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}