output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}


output "infra_admin_access_key_id" {
  value = aws_iam_access_key.infra_admin_key.id
}

output "infra_admin_secret_access_key" {
  value     = aws_iam_access_key.infra_admin_key.secret
  sensitive = true
}