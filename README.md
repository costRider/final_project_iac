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
