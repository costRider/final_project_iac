# Network CIDR Plan

본 문서는 `final_project_iac`에서 사용하는 **멀티클라우드 DR 네트워크 CIDR 설계 규칙**을 정의한다.  
AWS와 GCP VPC를 **대칭 구조**로 구성하는 것을 목표로 한다.

---

## 1. 설계 원칙
1. Cloud 별 CIDR 구성
2. AWS / GCP 간 충돌 없는 대역 설계(IP로 구분가능)
3. Subnet 타입(Public/App/DB) 규칙 고정
4. 고정 IP 규칙 적용(필요시)
5. Terraform 변수 구조 예시
6. 예외 CIDR 기록

---

## 2. 클라우드별 VPC CIDR 규칙

{project_general}.{cloud_code/env_code}.{subnet/az}.{0}/24

- 첫번째 옥텟
project_general: 10

- 두번째 옥텟
cloud_code: aws=1#, gcp=2#
env_code: dev=#0, stg=#1, prd=#2

- 세번째 옥텟
subent: public=1#, mgmt=2#, app=3#, db=4#
AZ: a=#0 ,b=#1, c=#2, d=#3 

### 예시 AWS의 개발환경 DB의 가용영역 C의 대역
CIDR = 10.10.42.0/24

---

## 3. 서브넷 CIDR 규칙

각 VPC 내에서 `/24` 단위 Subnet 구성.  
3번째 옥텟을 역할로 구분.

### 3.1 AWS 예시 (10.10.0.0/16)

| 용도 | AZ | CIDR | 예시 이름 |
|------|----|---------|-----------|
| Public | a | 10.12.10.0/24 | finalproj-aws-prd-apne2a-net-subnet-pub-01 |
| Public | c | 10.12.12.0/24 | finalproj-aws-prd-apne2c-net-subnet-pub-01 |
| Management | a | 12.12.20.0/24 | finalproj-aws-prd-apne2a-mgmt-subnet-pri-01 |
| Management | c | 12.12.22.0/24 | finalproj-aws-prd-apne2c-mgmt-subnet-pri-01 |
| App | a | 10.12.30.0/24 | finalproj-aws-prd-apne2a-app-subnet-prv-01 |
| App | c | 10.12.32.0/24 | finalproj-aws-prd-apne2c-app-subnet-prv-01 |
| DB | a | 10.12.40.0/24 | finalproj-aws-prd-apne2a-db-subnet-prv-01 |
| DB | c | 10.12.42.0/24 | finalproj-aws-prd-apne2c-db-subnet-prv-01 |


### 3.2 GCP 예시 (10.20.0.0/16) - 미정

| 용도              | Zone      | CIDR          |
| --------------- | --------- | ------------- |
| Public          | asia-ne3a | 10.20.10.0/24 |
| App             | asia-ne3a | 10.20.30.0/24 |
| DB              | asia-ne3a | 10.20.40.0/24 |
| (선택) Management | asia-ne3a | 10.20.20.0/24 |


멀티존 확장 시 AWS 규칙과 동일 패턴 적용.

---

## 4. 고정 IP 규칙 - (필요시)

Subnet 내 예약 IP:

- `.100+` : 특수 목적 서버

---

## 5. Terraform 변수 구조 예시
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

## 6. 예외 CIDR 기록

예외가 필요할 경우 문서 하단에 기록:

```
예: 10.30.50.0/24 - PoC 전용, 향후 삭제
```
