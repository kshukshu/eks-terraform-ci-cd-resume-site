# ☁️ Cloud Resume API on AWS EKS

This project is a cloud-native deployment of a simple `/visits` API using AWS infrastructure, Kubernetes, Terraform, and GitHub Actions. It is part of a hands-on DevOps portfolio.

---

## 🚀 Current Status

✅ Infrastructure built with Terraform  
✅ API containerized with Docker & pushed to ECR  
✅ Deployed on EKS with LoadBalancer access  
✅ Accessible via public ALB DNS  
✅ Cost-optimized: ALB removed, EC2 nodes scaled to 0  
✅ CI/CD automated via GitHub Actions (kubectl apply on push to main)  
✅ Next: Add monitoring with CloudWatch

---

## 🧱 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml                   # GitHub Actions workflow for CI/CD
├── app/
│   ├── main.py                         # FastAPI app for /visits endpoint
│   └── Dockerfile                      # Container configuration
├── k8s/
│   ├── deployment.yaml                 # Kubernetes Deployment for visits-api
│   ├── service.yaml                    # Kubernetes Service (ALB)
│   └── cloudwatch-agent.yaml           # DaemonSet for CloudWatch Agent
├── infra/                              # Terraform project root
│   ├── iam.tf                          # IAM users, roles, policies (infra-admin, EKS, CloudWatch)
│   ├── k8s.tf                          # K8s resources (ServiceAccount, aws-auth ConfigMap)
│   ├── main.tf                         # EKS cluster, node group, VPC module
│   ├── oidc.tf                         # OIDC provider for IRSA
│   ├── outputs.tf                      # Terraform outputs (e.g., subnet IDs, keys)
│   ├── provider.tf                     # AWS & Kubernetes provider config
│   ├── terraform.tfvars                # Variable values (e.g., region, cluster name)
│   ├── variables.tf                    # Terraform variable definitions
│   ├── terraform.tfstate               # Terraform state file (excluded from Git)
│   └── .terraform/                     # Plugin/module cache (excluded from Git)
└── README.md
```

---

## 🌐 API Overview

- **Endpoint:** `/visits`
- **Method:** `GET`
- **Response Example:**


{
  "count": 123
}


---

## ☸️ Kubernetes Deployment

* **Cluster:** AWS EKS (`resume-eks-cluster`)
* **Node Group:** t3.small (1 node, scalable)
* **Ingress:** AWS Load Balancer (ALB, deleted for cost savings)
* **Container Registry:** Amazon ECR

---

## 🔁 CI/CD with GitHub Actions

CI/CD is handled via a GitHub Actions workflow (`.github/workflows/deploy.yml`) that runs on every push to the `main` branch.

### ✅ Workflow Steps

1. Checkout source code
2. Configure AWS credentials using GitHub Secrets
3. Load `kubeconfig` from Secrets and apply Kubernetes manifests

### 🔐 GitHub Secrets Required

| Name                    | Description                                 |
| ----------------------- | ------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Access key for `infra-admin` IAM user       |
| `AWS_SECRET_ACCESS_KEY` | Secret key for `infra-admin`                |
| `KUBECONFIG_DATA`       | Base64-encoded kubeconfig (no `exec` block) |

> `kubeconfig` must not contain `AWS_PROFILE` or `exec` block. Authentication is handled via `aws-actions/configure-aws-credentials`.

---

## 🧪 Deployment Verification

Last successful test:


curl http://<alb-dns-name>/visits
# Output: {"count":123}


> ✅ ALB removed for cost savings. Recreate with:


kubectl apply -f k8s/service.yaml


---

## 📉 Cost Control Notes

* Node group scaled to 0: `desired_size = 0`
* ALB deleted with: `kubectl delete svc visits-api-service`
* No running EC2 = minimal hourly costs
* EKS base fee applies (\~\$30/month)

---

## 📊 CloudWatch Monitoring

The CloudWatch Agent DaemonSet collects logs from `/var/log/cloud-init-output.log` and sends them to Amazon CloudWatch Logs.

### 🔧 Configuration Overview

* **File:** `cloudwatch-agent.yaml`
* **Resources Included:** Namespace, ServiceAccount with IAM role binding, ConfigMap (agent settings), DaemonSet (deployment)
* **Purpose:** Collect and ship logs from EKS nodes to CloudWatch

### 📊 Key IAM Setup (via IRSA)

| Resource Type             | Description                                                                |
| ------------------------- | -------------------------------------------------------------------------- |
| OIDC Provider             | Declared using Terraform (`aws_iam_openid_connect_provider`)               |
| IAM Role                  | `EKSCloudWatchAgentRole` with `CloudWatchAgentServerPolicy` attached       |
| ServiceAccount Annotation | `eks.amazonaws.com/role-arn` links the SA to the IAM role (IRSA mechanism) |

### 🤖 Verification Steps

1. Open a debug shell in the `cloudwatch-agent` pod:

```bash
kubectl exec -it -n amazon-cloudwatch <pod-name> -c debug-shell -- sh
```

2. Write a test log:

```bash
echo "Test log $(date)" >> /host/var/log/cloud-init-output.log
```

3. Check CloudWatch Logs under the group:

```
/aws/containerinsights/resume-eks-cluster/application
```

Log streams should be created per node (using `{hostname}`).

---

## 🛠️ Operational Challenges & Fixes (Updated)

| Issue                                       | Resolution                                                                                |
| ------------------------------------------- | ----------------------------------------------------------------------------------------- |
| CloudWatch logs not appearing               | IRSA misconfigured; fixed trust policy and added OIDC provider                            |
| `spec` field validation errors in DaemonSet | Moved `hostNetwork`, `hostPID`, etc. under `spec.template.spec`                           |
| LogGroup/Stream missing                     | Updated `log_group_name` and dynamic `log_stream_name` to use `{hostname}` for uniqueness |

---

## 🛠️ Operational Challenges & Fixes

| Issue                                    | Resolution                                                                        |
| ---------------------------------------- | --------------------------------------------------------------------------------- |
| `Too many pods` on t3.micro              | Switched to `t3.small`                                                            |
| `InvalidRequestException` for node group | `terraform taint` + re-apply                                                      |
| `kubectl apply` fails in GitHub Actions  | Removed `exec` & `AWS_PROFILE` from kubeconfig; added AWS credentials via Secrets |

These reflect real-world troubleshooting scenarios and reinforce IaC best practices.



---

## 📘 Author

Built by [Shuhei Kato](https://github.com/katoshuhei)
As part of a hands-on cloud engineering challenge and portfolio.