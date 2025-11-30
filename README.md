# final_project_iac

This repository provides the infrastructure-as-code scaffolding for AWS and GCP environments. It includes Terraform modules, environment configurations, shared Kubernetes assets, and supporting documentation/scripts.

## Repository structure
- `docs/` – project documentation placeholders.
- `aws/` – AWS-specific Terraform configuration.
  - `global/` – shared provider/backend/version settings.
  - `modules/` – reusable AWS modules (VPC, EKS, RDS, ALB, EFS, IAM).
  - `envs/` – environment overlays (dev, stg, prd).
- `gcp/` – GCP-specific Terraform configuration.
  - `global/` – shared provider/backend/version settings.
  - `modules/` – reusable GCP modules (VPC, GKE, Cloud SQL, Load Balancer, IAM).
  - `envs/` – environment overlays (dev, stg, prd).
- `shared/` – common modules and Kubernetes manifests.
  - `modules/` – cross-cloud helpers (e.g., naming and tags).
  - `k8s/` – base and cloud-specific Kubernetes resources.
- `scripts/` – automation helpers.
- `diagrams/` – architecture diagrams.

Each Terraform directory includes placeholder files (e.g., `main.tf`, `variables.tf`, `outputs.tf`) to outline expected content.

## Terraform 관리 범위

Terraform은 다음 리소스를 관리합니다.

- AWS 계정 내 VPC, Subnet, Route, IGW/NATGW
- EKS Cluster 및 Node Group
- RDS, EFS, IAM Role, Security Group
- (선택) ALB Controller, CSI Driver 등 인프라 애드온

다음 리소스는 **Terraform이 관리하지 않습니다.**

- 애플리케이션 배포 리소스 (Deployment, Service, Ingress 등) → ArgoCD + GitOps
- 모니터링 스택(Prometheus/Grafana/Loki/Alloy)의 Helm 배포 → 별도 GitOps repo 예정


## 변경 프로세스 (초기 수동 → 이후 CI/CD 예정)

1. `feature/xxx` 브랜치에서 코드 수정
2. 로컬에서 `terraform plan` 실행 (envs/dev 기준)
3. PR 생성 후 리뷰
4. main 브랜치 머지 후, 수동으로 `terraform apply` 실행
5. (향후) GitHub Actions에서 `plan`/`apply` 자동화 예정
