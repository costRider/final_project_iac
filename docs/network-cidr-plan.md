# Network CIDR Plan

본 문서는 `final_project_iac`에서 사용하는 **멀티클라우드 DR 네트워크 CIDR 설계 규칙**을 정의한다.  
AWS와 GCP VPC를 **대칭 구조**로 구성하는 것을 목표로 한다.

---

## 1. 설계 원칙
1. 환경(dev/stg/prd)별 고유 CIDR
2. AWS / GCP 간 충돌 없는 대역 설계
3. Subnet 타입(Public/App/DB) 규칙 고정
4. DR에서 구조적 대응 가능하도록 패턴 유지

---

## 2. 환경별 CIDR 블록

| Env | Base CIDR |
|-----|-----------|
| dev | 10.10.0.0/16 |
| stg | 10.20.0.0/16 |
| prd | 10.30.0.0/16 |

---

## 3. 클라우드별 VPC CIDR 규칙

env별 /16에서 cloud별로 /20 또는 /16 분리:

env_code: dev=10, stg=20, prd=30  
cloud_code: aws=10, gcp=20

### 예시(PRD)
- AWS VPC: `10.30.10.0/20`
- GCP VPC: `10.30.20.0/20`

DEV/STG도 동일 패턴 적용.

---

## 4. 서브넷 CIDR 규칙

각 VPC 내에서 `/24` 단위 Subnet 구성.  
3번째 옥텟을 역할로 구분.

### 4.1 AWS 예시 (10.30.10.0/20)

| 용도 | AZ | CIDR | 예시 이름 |
|------|----|---------|-----------|
| Public | a | 10.30.10.1.0/24 | finalproj-prd-aws-apne2a-net-subnet-pub-01 |
| Public | c | 10.30.10.2.0/24 | finalproj-prd-aws-apne2c-net-subnet-pub-01 |
| Management | a | 10.30.10.11.0/24 | finalproj-prd-aws-apne2a-mgmt-subnet-pri-01 |
| Management | c | 10.30.10.12.0/24 | finalproj-prd-aws-apne2c-mgmt-subnet-pri-01 |
| App | a | 10.30.10.21.0/24 | finalproj-prd-aws-apne2a-app-subnet-prv-01 |
| App | c | 10.30.10.22.0/24 | finalproj-prd-aws-apne2c-app-subnet-prv-01 |
| DB | a | 10.30.10.31.0/24 | finalproj-prd-aws-apne2a-db-subnet-prv-01 |
| DB | c | 10.30.10.32.0/24 | finalproj-prd-aws-apne2c-db-subnet-prv-01 |

### 4.2 GCP 예시 (10.30.20.0/20)

| 용도 | Zone | CIDR |
|------|--------|---------|
| Public | asia-ne3a | 10.30.20.1.0/24 |
| Management | asia-ne3a | 10.30.20.11.0/24 |
| App | asia-ne3a | 10.30.20.21.0/24 |
| DB | asia-ne3a | 10.30.20.31.0/24 |

멀티존 확장 시 AWS 규칙과 동일 패턴 적용.

---

## 5. 고정 IP 규칙

Subnet 내 예약 IP:

- `.10` : Bastion / Jump
- `.11` : VPN GW / On-prem Tunnel endpoint
- `.100+` : 특수 목적 서버

---

## 6. DR 매핑

Primary(AWS apne2) ↔ DR(GCP asia-ne3) 매핑 기준:

- AWS VPC: `10.30.10.0/20`
- GCP VPC: `10.30.20.0/20`

Public/App/DB subnet 구조 동일하게 유지.

---

## 7. Terraform 변수 구조 예시
naming 은 naming-conventions.md를 참조한다.
```hcl
variable "environment" {}
variable "cloud" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_mgmt_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
```

---

## 8. 예외 CIDR 기록

예외가 필요할 경우 문서 하단에 기록:

```
예: 10.30.50.0/24 - PoC 전용, 향후 삭제
```
