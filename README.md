# final_project_iac

This repository provides fully automated Infrastructure-as-Code (IaC) for AWS & GCP environments using **Terraform**, with an enhanced architecture that now includes a fully automated **MGMT EC2 bootstrap**, **self-hosted GitHub Actions Runner**, and a **GitOps-based addon deployment pipeline**.

---

# 📁 Repository Structure

```
final_project_iac/
│
├── aws/
│   ├── global/        # Shared provider & backend config
│   ├── modules/       # Reusable AWS modules (VPC, EKS, RDS, ALB, etc.)
│   └── envs/          # Dev/Stg/Prod environment stacks
│
├── gcp/
│   ├── global/        # Shared provider & backend config
│   ├── modules/       # Reusable GCP modules (VPC, GKE, CloudSQL, etc.)
│   └── envs/          # Dev/Stg/Prod environment stacks
│
├── shared/
│   ├── modules/       # Naming, tagging, cross-cloud helpers
│   └── k8s/           # Base manifests and cloud-specific Kubernetes assets
│
├── scripts/           # Automation scripts (CI/CD helpers, tooling)
├── docs/              # Docs & architecture references
└── diagrams/          # Architecture PNG / SVG files
```

---

# 🧩 Terraform 관리 범위

### Terraform으로 관리되는 리소스
- VPC, Subnet, Route Table, IGW/NATGW
- EKS Cluster & Node Group
- RDS, EFS, IAM Roles, Security Groups
- (필요 시) Cluster-level addon IAM roles (LBC, CSI Driver 등)

### Terraform으로 관리되지 않는 리소스
| 비관리 영역 | 이유 |
|-------------|------|
| Kubernetes App Manifests | GitOps(ArgoCD)로 지속 관리 |
| Monitoring Stack (Prometheus/Grafana/Loki/Alloy) | 별도 CI/CD 파이프라인에서 Helm 배포 |
| Runtime-level Secret Syncing | ExternalSecrets 로 관리 |

---

# 📘 Infrastructure Improvement Summary  
### *Terraform Infra + MGMT EC2 + GitHub Actions Runner 자동화 구조 개선 내용 정리*

본 문서는 기존 인프라 구성에서 어떤 문제가 있었고, 어떻게 개선되었는지를 설명합니다.

---

# 🚀 1. 기존 인프라 구조의 문제점

기존 구성 흐름:

1. **CodeServer → Terraform apply → VPC/EKS/RDS 등 인프라 생성**
2. **MGMT EC2에 직접 SSH 접속**
   - kubectl/helm 설치 수동
   - kubeconfig 생성 수동
   - LBC / ArgoCD 등 Addon 설치 수동
3. 인프라 생성과 후속 구성(Addon배포)이 완전히 **단절된 단일 작업 흐름**

### 🔥 주요 문제점 요약

| 문제점 | 설명 |
|-------|------|
| ❌ 자동화 단절 | Terraform 이후 모든 추가 구성은 사람이 직접 수행 |
| ❌ 재현성 부족 | 매번 설치 과정이 달라지고 실수 가능성 증가 |
| ❌ CI/CD 단절 | GitHub Actions가 내부 EKS에 접근 불가 → Runner 필요 |
| ❌ 초기화 불안정 | kubeconfig/Helm 설정 등이 작업자마다 달라짐 |
| ❌ 확장성 부족 | Dev/Stg/Prod 환경 분리 시 반복 작업 증가 |

---

# ✨ 2. 개선된 인프라 아키텍처

개선 후 전체 동작 흐름:

```
Terraform Apply (CodeServer)
        │
        ▼
MGMT EC2 자동 부팅 스크립트(user_data)
        ├─ AWS CLI / kubectl / helm / terraform 자동 설치
        ├─ EKS kubeconfig 자동 구성
        ├─ GitHub PAT (SSM) 자동 Load
        ├─ GitHub Runner 자동 설치 + systemd 서비스 등록
        ▼
Runner Online
        ▼
GitHub Actions → EKS Addon 자동 배포 (LBC, ArgoCD, ExternalSecrets 등)
```

🎉 **이제 Terraform apply 한 번이면 전체 인프라 + Addon + Runner까지 자동 구성됨**

---

# 🛠 3. 주요 변경점 상세

## ✔ 3-1. MGMT EC2 user_data 전면 리팩토링

### 기존
- kubectl/helm 설치를 사람이 직접 수행  
- kubeconfig 수동 생성  
- Runner 설치·등록 수동  
- 설치 누락/권한 문제 빈번 발생  

### 변경 후
- kubectl, helm, terraform 자동 설치
- EKS kubeconfig 자동 생성
- GitHub PAT 자동 수신(SSM)
- GitHub Runner **자동 설치 → 자동 등록 → systemd 서비스 자동 실행**
- Amazon Linux 2023 의 .NET/ICU 의존성 해결
- 파일 권한 문제(chown) 자동 처리

➡ **MGMT EC2 자체가 “완전 자동화 DevOps 실행 엔진”으로 변화**

---

## ✔ 3-2. GitHub Actions Self-Hosted Runner 자동화

### 기존
- Runner 설치 / 권한 설정 / 서비스 등록 모두 수동
- Runner 버전 문제로 deprecated 오류 발생
- GitHub Actions → EKS 연결 불가

### 변경 후
- GitHub Release API 기반 최신 Runner 버전 자동 감지
- config.sh + svc.sh 자동 실행
- Runner가 systemd 에 올라가 자동으로 기동
- GitHub와의 연결 상태 자동 유지

➡ **CI/CD가 EKS에 직접 배포할 수 있는 구조 완성**

---

## ✔ 3-3. Terraform → Addon GitOps 배포 흐름 구축

### 기존
- Terraform apply 이후 사람이 helm install

### 변경 후
- Terraform apply → MGMT EC2 생성 + Runner 준비
- Addon repo(`final_project_iac_addon-`) 변경 → GitHub Actions 자동 실행
- Runner가 helm/kubectl 로 EKS에 직접 Addon 배포

➡ **Infra → Addon → GitOps의 완전 자동화 파이프라인 완성**

---

# 📈 4. 개선 효과 요약

| 개선 항목 | 기대 효과 |
|-----------|-----------|
| 💯 완전 자동화 | Terraform 한 번으로 전체 구조 완성 |
| 🔄 CI/CD 활성화 | GitHub Actions가 EKS 배포까지 담당 |
| 🔐 보안 강화 | GitHub PAT은 SSM Parameter Store에서 안전하게 주입 |
| 🔧 유지보수 쉬움 | Runner 최신 버전 자동 동기화 |
| 🚫 오류 감소 | 사람이 하던 설치 절차 제거 |
| 🧬 재현성 보장 | 동일 user_data 기반 → 언제든지 동일 환경 재생성 가능 |

---

# 📦 5. 전체 플로우 (요약)

```
Terraform (CodeServer)
  │
  ▼
MGMT EC2 생성 (user_data 자동 실행)
  ├─ AWS CLI / kubectl / helm / terraform 설치
  ├─ kubeconfig 자동 구성
  ├─ GitHub Runner 자동 설치/등록
  ▼
Runner Online
  ▼
GitHub Actions → Addon 자동 배포(LBC, ArgoCD, ExternalSecrets 등)
```

---

# 🧾 6. 결론

본 개선을 통해 기존 인프라는 단순한 Terraform 인프라 생성 수준에서 벗어나,

> **Infra 생성 → MGMT Init → Addon 배포 → GitOps/CI/CD 자동화**  
까지 이어지는 **End-to-End DevOps 자동화 구조**로 발전했다.

이제 인프라는 완전히 코드 중심으로 반복 가능하게 되었고,  
환경이 늘어나도 동일한 자동화 파이프라인을 그대로 적용할 수 있다.

---

# 🔥 TL;DR (Bro Edition)

- Terraform apply 한 번이면 **EKS + Addon + CI/CD Runner까지 자동 구성**
- MGMT에 SSH 접속해서 helm 설치하던 시대 끝남
- GitHub Actions가 EKS 내부 배포를 **직접 수행**
- 구조는 GitOps + IaC 형태로 매우 고도화됨

---

Made with ☕, Terraform, and a lot of debugging.
