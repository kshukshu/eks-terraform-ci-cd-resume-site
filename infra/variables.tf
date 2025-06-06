variable "aws_region" {
  description = "The AWS region to deploy resources into"
  default     = "eu-central-1"
  type        = string
}

variable "subnet_ids" {
  type = list(string)
}