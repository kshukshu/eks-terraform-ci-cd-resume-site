
# ☁️ Cloud Resume API on AWS EKS

This project is a cloud-native deployment of a simple `/visits` API using AWS infrastructure, Kubernetes, and Terraform. It is part of a hands-on DevOps portfolio.

---

## 🚀 Current Status

✅ Infrastructure built with Terraform  
✅ API containerized with Docker & pushed to ECR  
✅ Deployed on EKS with LoadBalancer access  
✅ Accessible via public ALB DNS  
✅ Cost-optimized: ALB removed, EC2 nodes scaled to 0  
🔜 Next: GitHub Actions for CI/CD automation

---

## 🧱 Project Structure

```

.
├── main.tf                 # Main Terraform infrastructure definitions
├── variables.tf            # Variable definitions
├── outputs.tf              # Output values (e.g., access keys, subnet IDs)
├── provider.tf             # AWS provider configuration
├── aws\_auth.tf             # EKS aws-auth ConfigMap setup
├── k8s/
│   ├── deployment.yaml     # Kubernetes Deployment for visits-api
│   └── service.yaml        # Kubernetes Service (LoadBalancer)
└── .github/
└── workflows/          # (To be added in Phase 4)

````

---

## 🌐 API Overview

- **Endpoint:** `/visits`
- **Method:** `GET`
- **Response Example:**

```json
{
  "count": 123
}
````

---

## ☸️ Kubernetes Deployment

* **Cluster:** AWS EKS (`resume-eks-cluster`)
* **Node Group:** t3.small (scalable via Terraform)
* **Ingress:** AWS Load Balancer (ALB)
* **Container Registry:** Amazon ECR

---

## 🧪 Deployment Verification

Last successful test:

```bash
curl http://<alb-dns-name>/visits
# Output: {"count":123}
```

> ✅ ALB removed for cost savings. Re-create with `kubectl apply -f k8s/service.yaml`.

---

## 📉 Cost Control Notes

* Node group currently scaled to 0 (`terraform apply` with desired\_size=0)
* ALB deleted (`kubectl delete svc visits-api-service`)
* No running EC2 instances = minimal hourly charges
* EKS base fee applies (approx. \$30/month)

---

## 📆 Next Steps (Phase 4 – CI/CD)

* Create GitHub Actions workflow:

  * Docker build & push to ECR
  * `kubectl apply` via GitHub
* Configure Secrets:

  * AWS\_ACCESS\_KEY\_ID / SECRET
  * Kubeconfig or OIDC-based credentials

---

## 📘 Author

Built by [Shuhei Kato](https://github.com/katoshuhei) as part of a hands-on cloud engineering challenge.

```

---

必要に応じて：
- `API仕様や画像（draw.ioのアーキテクチャ図）`
- `参考リンク`
- `学びや気づきのまとめ`

なども追記できます。調整したいポイントがあれば教えてください！
```
