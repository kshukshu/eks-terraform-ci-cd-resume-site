# ☁️ Cloud Resume API on AWS EKS

This project showcases a production-grade deployment pipeline for a simple `/visits` API using AWS infrastructure, Kubernetes, Terraform, and GitHub Actions. It is designed as a DevOps portfolio artifact to demonstrate hands-on experience with modern cloud-native infrastructure.

---

## 📌 Project Purpose

This system is not hosted publicly for cost reasons. Instead, it serves as a technical demonstration of:

* Infrastructure as Code (IaC) with Terraform
* Kubernetes cluster management via AWS EKS
* CI/CD automation with GitHub Actions
* Observability with CloudWatch and IRSA
* Cost-aware design decisions

---

## 🖼️ Architecture Overview

![Architecture Diagram](./cloud-resume-architecture.drawio.svg)

> This diagram outlines a fully containerized application deployed on EKS, managed via GitHub Actions and monitored through CloudWatch using IAM Roles for Service Accounts (IRSA).

---

## 🛠️ Tech Stack & Tooling

* **Cloud Provider:** AWS (EKS, VPC, EC2, IAM, ALB, ECR, CloudWatch)
* **Orchestration:** Kubernetes (v1.29)
* **IaC:** Terraform (modular layout)
* **CI/CD:** GitHub Actions with Secrets & `kubectl`
* **Monitoring:** CloudWatch Agent (DaemonSet with IRSA)
* **Language:** Python (FastAPI)
* **Containerization:** Docker

---

## 🔧 Infrastructure as Code (Terraform)

Terraform is used to provision all resources:

* VPC with public/private subnets
* EKS cluster & node group
* IAM roles including IRSA
* OIDC provider for service account binding
* Outputs for reuse (e.g., subnet IDs, kubeconfig)

Project structure:

```
infra/
├── main.tf                 # EKS cluster, node group, VPC
├── iam.tf                  # IAM for EKS & CloudWatch
├── oidc.tf                 # IRSA config
├── k8s.tf                  # aws-auth & service account
├── variables.tf            # Variables
├── outputs.tf              # Outputs
├── provider.tf             # AWS/K8s providers
├── terraform.tfvars        # Variable values
```

---

## ⚘️ Kubernetes on EKS

* **Cluster Name:** `resume-eks-cluster`
* **Node Group:** t3.small (Auto Scaling enabled)
* **Ingress:** ALB via Kubernetes Service (removed post-verification)
* **Namespace:** `default` (app), `amazon-cloudwatch` (agent)
* **Pods:** `visit-api`, `cloudwatch-agent`

---

## 🔄 CI/CD Pipeline (GitHub Actions)

CI/CD is triggered on every push to `main`, using `.github/workflows/deploy.yml`

### Workflow Steps:

1. Checkout repo
2. Configure AWS credentials from GitHub Secrets
3. Load base64 kubeconfig
4. Apply Kubernetes manifests with `kubectl`

### Required Secrets:

| Name                    | Use Case                       |
| ----------------------- | ------------------------------ |
| `AWS_ACCESS_KEY_ID`     | infra-admin user               |
| `AWS_SECRET_ACCESS_KEY` | secret for infra-admin         |
| `KUBECONFIG_DATA`       | kubeconfig (base64, no `exec`) |

---

## 📊 Monitoring with CloudWatch

A CloudWatch Agent DaemonSet ships logs from each EC2 node (e.g., `/var/log/cloud-init-output.log`) to CloudWatch Logs.

### Key Components:

* **DaemonSet:** `cloudwatch-agent`
* **IAM Role:** `EKSCloudWatchAgentRole` via IRSA
* **ServiceAccount:** Annotated with `eks.amazonaws.com/role-arn`
* **LogGroup:** `/aws/containerinsights/resume-eks-cluster/application`

### Log Verification:

```bash
kubectl exec -it -n amazon-cloudwatch <pod> -c debug-shell -- sh
echo "Test log $(date)" >> /host/var/log/cloud-init-output.log
```

---

## 🧠 Testing & Debugging Examples

After applying the manifests:

```bash
kubectl get svc visits-api-service
curl http://<external-alb-dns>/visits
# Output: {"count": 123}
```

> Note: ALB and nodes are shut down by default for cost reasons. Redeploy using `kubectl apply -f k8s/service.yaml` if needed.

---

## ⚠️ Operational Challenges & Fixes

| Issue                                       | Resolution                                                     |
| ------------------------------------------- | -------------------------------------------------------------- |
| CloudWatch logs not appearing               | Fixed IRSA trust policy & verified OIDC                        |
| `spec` validation in DaemonSet              | Moved `hostNetwork` under `template.spec`                      |
| `Too many pods` on t3.micro                 | Switched to t3.small                                           |
| Node group errors (InvalidRequestException) | Used `terraform taint` to recreate nodes                       |
| `kubectl` failed in GitHub Actions          | Removed `exec`/`AWS_PROFILE`, used `configure-aws-credentials` |

---

## 📉 Cost Optimization Strategies

* Deleted ALB (`kubectl delete svc visits-api-service`)
* Scaled node group to 0 (`desired_size = 0`)
* No EC2 instances running by default
* EKS base fee applies (\~\$30/month)

> The architecture is intentionally designed to be cost-efficient while remaining reproducible.

---

## 📁 Project Directory Structure

```
.
├── app/
│   ├── main.py                  # FastAPI app
│   └── Dockerfile               # Build config
├── k8s/
│   ├── deployment.yaml          # visit-api deployment
│   ├── service.yaml             # ALB service
│   └── cloudwatch-agent.yaml    # DaemonSet config
├── infra/                       # Terraform config
├── .github/workflows/
│   └── deploy.yml               # CI/CD pipeline
└── README.md
```

---

## 👤 Author

Built by [Shuhei Kato](https://github.com/kshukshu) as part of a personal DevOps portfolio challenge.

For feedback, collaboration, or hiring inquiries, feel free to connect via GitHub.
