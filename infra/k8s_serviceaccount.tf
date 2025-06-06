resource "kubernetes_service_account" "cloudwatch_agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = "amazon-cloudwatch"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cloudwatch_agent.arn
    }
  }
  depends_on = [aws_iam_role.cloudwatch_agent]
}