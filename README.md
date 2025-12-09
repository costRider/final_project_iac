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

---

📘 Infrastructure Improvement Summary
Terraform Infra + MGMT EC2 + GitHub Actions Runner 자동화 구조 개선 내용 정리

본 문서는 기존 인프라 구성에서 개선된 점들을 체계적으로 정리하며,
현재 적용된 아키텍처의 주요 변경 사항과 그로 인해 확보된 안정성, 자동화 수준, 운영 효율성을 설명합니다.

🚀 1. 기존 인프라 구조의 문제점

기존 구성은 다음과 같은 흐름이었음:

CodeServer에서 Terraform apply → 기본 Infra 생성 (VPC, Subnets, EKS, RDS 등)

생성된 MGMT EC2에 직접 접속 → git clone → kubectl/helm 설치 → EKS addon 설치(LBC, ArgoCD 등)

인프라 생성과 Addon 배포가 두 단계로 분리되어 인간 개입이 필요

🔥 기존 구조의 주요 문제점
문제점	설명
❌ 자동화 단절	Terraform apply 후 MGMT에 접속해 수동으로 addons 설치해야 했음
❌ 재현성 부족	매번 사람이 직접 들어가 설치 → 실수·누락 가능
❌ CI/CD 연결 어려움	GitHub Actions가 EKS 내부 리소스를 생성하려면 Runner가 필요하지만, Runner는 수동 설치였음
❌ MGMT EC2의 초기화가 불완전	kubeconfig, 권한 설정, 헬름 설치 등 일관성 유지 어려움
❌ 확장 불가한 구조	인프라 전체 자동화 파이프라인으로 연결되지 않음
✨ 2. 개선된 인프라 아키텍처

이번 개선 작업을 통해 다음과 같은 “완전 자동화 구조”가 만들어짐:

CodeServer → Terraform apply (Infra 생성 + MGMT EC2 생성)

MGMT EC2의 user_data가 부팅 시 자동으로 다음 작업을 수행

AWS CLI / kubectl / helm / terraform 설치

EKS kubeconfig 자동 구성 (aws eks update-kubeconfig)

GitHub PAT SSM에서 Load

GitHub Runner 자동 설치 + systemd 서비스 등록 + 기동

GitHub Actions Workflow가 자동으로 Addons(LBC, ArgoCD 등) 배포 실행

🎉 결과적으로…

Terraform apply 한 번으로
인프라 + MGMT + Addons + CI/CD Runner까지 모두 자동 생성되는 구조가 완성됨

🛠 3. 주요 변경점 상세 정리
✔ 3-1. MGMT EC2 user_data 전면 리팩토링
기존

단순히 awscli / kubectl 설치 정도만 수행

Github Runner 설치는 사람이 수동으로 수행

kubeconfig 생성도 수동

변경 후

kubectl / helm / terraform 자동 설치

kubeconfig 자동 생성

GitHub PAT을 SSM Parameter Store에서 자동 불러오기

GitHub Runner 자동 설치 + 자동 등록 + systemd 서비스 자동 실행

Amazon Linux 2023 환경에서 필요한 .NET + libicu 종속성 자동 해결

파일 권한 문제(chown) 해결하여 Runner가 안정적으로 실행되도록 설계

➡ MGMT EC2 자체가 “완전한 DevOps 자동화 엔진”이 됨

✔ 3-2. GitHub Actions Self-Hosted Runner 자동화
기존

수동으로 Runner 설치

버전 관리 불가 → Runner 버전 문제로 Offline 되거나 Deprecated 에러 발생

Runner 서비스 실행/관리도 수동

변경 후

Runner 버전 자동 감지(releases/latest)

Runner 자동 설치 및 구성(config.sh)

systemd 서비스 자동 생성(svc.sh install)

시스템 부팅 시 자동 기동

GitHub와 실시간 연결 상태 유지

➡ CI/CD가 EKS 내부에 Addon을 배포할 수 있는 “자동화 실행 환경” 확보

✔ 3-3. Terraform → Addons GitHub Actions 파이프라인 구축
기존

Terraform apply 후 사람이 MGMT에 수동 접속

helm/kubectl 명령으로 LBC, ArgoCD 배포

변경 후

Terraform apply → MGMT EC2 + Runner 자동 구성

final_project_iac_addon- repo가 push 되면 GitHub Actions 자동 실행

Runner가 직접 MGMT 내부에서 EKS에 접근하여 helm install 수행

➡ “Infra → Addons” 모두 GitOps 기반 자동화로 전환

📈 4. 개선 효과
개선 항목	효과
💯 완전 자동화	Terraform apply → 인프라 + Addons까지 모두 자동 구성
🔄 CI/CD 정착	Self-hosted GitHub Runner 활성화 → EKS Addon 자동 배포 가능
🔐 보안 강화	PAT은 SSM Parameter Store에서 안전하게 제공
🔧 유지보수 용이	Runner 버전 자동 업데이트 및 지원 버전 동기화
🚫 오류 감소	사람이 수동으로 설치하던 모든 과정 제거
🧬 재현성 확보	동일 user_data 기반 → 환경 재구축이 100% 동일하게 반복 가능
📦 5. 전체 흐름도 (요약)
Terraform (CodeServer)
        │
        ▼
MGMT EC2 생성
        │ (user_data 자동 실행)
        ├─ AWS CLI / kubectl / helm / terraform 설치
        ├─ kubeconfig 자동 생성
        ├─ GitHub PAT 가져오기
        ├─ GitHub Runner 자동 등록 + 서비스 기동
        ▼
Runner Online
        │
GitHub Actions → Addon 자동 배포 (LBC, ArgoCD, ExternalSecrets 등)

🧾 6. 결론

이번 개선으로 인해 인프라 자동화 레벨은 단순 “Terraform 리소스 생성” 단계에서 벗어나,

Infra 생성 → MGMT Init → Addon 구성 → CI/CD 연결
까지 이어지는 진짜 end-to-end DevOps 자동화 구조로 발전했다.

재현성, 안정성, 운영성 모두 개선되었으며
현재 구조는 규모 확장과 환경 분리(Dev/Staging/Prod)에도 쉽게 적용 가능하다.

🔥 Bro 버전 TL;DR

이제 Terraform apply 한 번이면 EKS + Addon + Runner까지 다 자동 설치됨

MGMT 들어가서 helm apply → kubectl apply → runner 설치… 다 수동이 사라짐

GitHub Actions가 EKS 내부 배포까지 자동으로 처리

완성도가 매우 높은 IaC + GitOps 구조로 진화됨