
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.infra_admin_role.arn
        username = "infra-admin"
        groups   = ["system:masters"]      
      },
      {
      rolearn  = aws_iam_role.eks_node.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}