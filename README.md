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
🔜 Next: Add monitoring with CloudWatch

---

## 🧱 Project Structure

```

.
├── main.tf                 # Terraform: IAM, EKS cluster, node group
├── variables.tf            # Terraform: reusable variables
├── outputs.tf              # Terraform: outputs (e.g., keys, cluster name)
├── provider.tf             # Terraform: AWS provider config
├── aws\_auth.tf             # Terraform: EKS aws-auth ConfigMap
├── k8s/
│   ├── deployment.yaml     # K8s Deployment for visits-api
│   └── service.yaml        # K8s LoadBalancer Service
├── app/
│   ├── main.py             # FastAPI app
│   └── Dockerfile          # Container config
└── .github/
└── workflows/
└── deploy.yml      # GitHub Actions workflow for CI/CD

````

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

## 🛠️ Operational Challenges & Fixes

| Issue                                    | Resolution                                                                        |
| ---------------------------------------- | --------------------------------------------------------------------------------- |
| `Too many pods` on t3.micro              | Switched to `t3.small`                                                            |
| `InvalidRequestException` for node group | `terraform taint` + re-apply                                                      |
| `kubectl apply` fails in GitHub Actions  | Removed `exec` & `AWS_PROFILE` from kubeconfig; added AWS credentials via Secrets |

These reflect real-world troubleshooting scenarios and reinforce IaC best practices.

---

## 📆 Next Steps

**Phase 5 – Monitoring & Observability**

* Enable CloudWatch Container Insights
* Capture logs & metrics from pods
* Optional: set alarms or use Lambda triggers

---

## 📘 Author

Built by [Shuhei Kato](https://github.com/katoshuhei)
As part of a hands-on cloud engineering challenge and portfolio.