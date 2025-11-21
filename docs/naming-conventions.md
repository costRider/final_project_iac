# Naming Conventions

본 문서는 `final_project_iac` 리포지토리에서 사용하는 **멀티클라우드(AWS/GCP) DR 인프라 네이밍 규칙**을 정의한다.  
모든 IaC(Terraform), Kubernetes, Cloud 리소스는 본 규칙을 따른다.

---

## 1. 공통 원칙

리소스 작성 시 공통 태그를 부여하여 관리를 명확히 한다.

예) terraform 자동화 리소스 생성 시 아래와 같은 공통 태그를 default_tags 로 부여 (생성 시 변수형태로 삽입)
  common_tags ={
    Project     = "petclinic" // 현재 프로젝트명
    Environment = "dev" // 배포된 환경
    Owner       = "mklee" //작성자
    ManagedBy  = "Terraform" //작성된 도구
  }
  
### 1.1 문자 규칙
- 소문자 알파벳 + 숫자 + 하이픈(`-`) 사용
- 언더스코어(`_`), 공백, 대문자 금지
- 이름은 짧고 의미를 명확히

### 1.2 네이밍 기본 패턴

```
{project}-{env}-{cloud}-{region}{zone?}-{layer}-{component}-{seq}
```

| 필드 | 설명 |
|------|------|
| project | 프로젝트 식별자 (finalproj, petclinic 등) |
| env | dev / stg / prd |
| cloud | aws / gcp |
| region/zone | apne2, apne2a, asia-ne3, asia-ne3a |
| layer | net, app, db, obs |
| component | vpc, subnet-pub, subnet-prv, eks, gke, rds, csql 등 |
| seq | 01, 02 … |

### 예시

```
finalproj-prd-aws-apne2-net-vpc-01
finalproj-prd-aws-apne2a-net-subnet-pub-01
finalproj-prd-gcp-asia-ne3-app-gke-cluster-01
finalproj-prd-gcp-asia-ne3-db-csql-pg-01
```

---

## 2. AWS 네이밍 규칙 예시

### 2.1 VPC
```
finalproj-prd-aws-apne2-net-vpc-01
```

### 2.2 Subnets
```
finalproj-prd-aws-apne2a-net-subnet-pub-01
finalproj-prd-aws-apne2a-mgmt-subnet-prv-01
finalproj-prd-aws-apne2a-app-subnet-prv-01
finalproj-prd-aws-apne2a-db-subnet-prv-01
```

### 2.3 Security Group
```
finalproj-prd-aws-apne2-net-sg-bastion-01
finalproj-prd-aws-apne2-mgmt-sg-control-01
finalproj-prd-aws-apne2-app-sg-web-01
finalproj-prd-aws-apne2-db-sg-rds-01
```

### 2.4 Load Balancer
```
finalproj-prd-aws-apne2-app-lb-alb-01
finalproj-prd-aws-apne2-app-lb-nlb-01
```

### 2.5 EKS
```
finalproj-prd-aws-apne2-app-eks-cluster-01
finalproj-prd-aws-apne2-app-eks-ng-app-01
finalproj-prd-aws-apne2-obs-eks-ng-obs-01
finalproj-prd-aws-apne2-obs-eks-ng-other-01
```

### 2.6 RDS
```
finalproj-prd-aws-apne2-db-rds-pg-01
finalproj-prd-aws-apne2-db-rds-mysql-01
finalproj-prd-aws-apne2-db-aurora-mysql-01
```

---

## 3. GCP 네이밍 규칙

### 3.1 Project ID
```
finalproj-prd-gcp-main
finalproj-dev-gcp-lab
```

### 3.2 VPC/Subnet
```
finalproj-prd-gcp-asia-ne3-net-vpc-01
finalproj-prd-gcp-asia-ne3a-net-subnet-pub-01
finalproj-prd-gcp-asia-ne3a-mgmt-subnet-prv-01
finalproj-prd-gcp-asia-ne3a-app-subnet-prv-01
finalproj-prd-gcp-asia-ne3a-db-subnet-prv-01
```

### 3.3 GKE
```
finalproj-prd-gcp-asia-ne3-app-gke-cluster-01
finalproj-prd-gcp-asia-ne3-obs-gke-np-obs-01
```

### 3.4 Cloud SQL
```
finalproj-prd-gcp-asia-ne3-db-csql-pg-01
finalproj-prd-gcp-asia-ne3-db-csql-mysql-01
```

### 3.5 Firewall
```
finalproj-prd-gcp-asia-ne3-net-fw-allow-web-01
finalproj-prd-gcp-asia-ne3-db-fw-allow-db-01
```

---

## 4. Kubernetes 네이밍 규칙

### 4.1 Namespace
```
{project}-{env}-{layer}
```
예:
```
finalproj-prd-app
finalproj-prd-obs
```

### 4.2 Deployment / StatefulSet / DaemonSet
```
finalproj-prd-petclinic-web
finalproj-prd-petclinic-api
```

### 4.3 Service
```
finalproj-prd-petclinic-svc
```

### 4.4 HPA
```
finalproj-prd-petclinic-hpa
```

### 4.5 ConfigMap / Secret
```
finalproj-prd-petclinic-cm-app
finalproj-prd-petclinic-sec-db
```

---

## 5. Kubernetes 라벨 규칙

```yaml
metadata:
  labels:
    app.kubernetes.io/name: <service>
    app.kubernetes.io/instance: <project-env>
    app.kubernetes.io/component: <role>
    app.kubernetes.io/part-of: finalproj-system
    env: prd
    layer: app
    cloud: aws
```

---

## 6. Terraform 변수 네이밍 규칙
snake_case 사용:

```
project_name
environment
aws_region
gcp_region
vpc_cidr
public_subnet_cidrs
private_app_subnet_cidrs
private_db_subnet_cidrs
```

---

## 7. 예외 처리
- CSP 특성으로 이름 길이 제한 시 component/project 축약
- 예외 발생 시 문서 하단에 기록
