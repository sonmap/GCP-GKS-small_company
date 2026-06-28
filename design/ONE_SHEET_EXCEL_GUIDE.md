# One Sheet Excel Design Guide

이 문서는 `GCP GKE Small Company` 환경을 엑셀 1장으로 설계한 뒤 Terraform 적용값으로 변환하는 절차입니다.

## 1. 기본 원칙

엑셀 파일은 시트를 여러 개로 나누지 않고 `GCP_GKE_Design` 한 시트만 사용합니다.

핵심 컬럼은 다음입니다.

| Column | Meaning |
|---|---|
| `Section` | 적용 단계: `00-google-identity`, `10-network`, `20-gke`, `30-gke-rbac` |
| `Resource Type` | 리소스 유형: `VPC_NETWORK`, `GKE_CLUSTER`, `K8S_ROLE_BINDING` 등 |
| `Enabled` | `TRUE`이면 적용 대상, `FALSE`이면 설계만 보관 |
| `Apply Order` | 적용 순서 |
| `Resource Key` | 행의 고유 키 |
| `Depends On` | 선행 리소스 키 |
| `Project ID` | GCP Project ID |
| `Region` | GCP region, 예: `asia-northeast3` |
| `Generated File` | 스크립트가 생성할 tfvars/csv 대상 |

## 2. 포함 리소스

엑셀 한 장에 다음 속성을 모두 넣습니다.

- Project Service API
- Google Workspace / Cloud Identity User
- Google Group
- Group Membership
- Google Cloud IAM
- VPC Network
- Subnetwork
- GKE Pod/Service Secondary Range
- Firewall Rule
- Artifact Registry
- GKE Node Service Account
- GKE Cluster
- GKE Node Pool
- Kubernetes Namespace
- Kubernetes Role
- Kubernetes RoleBinding

## 3. 사용 절차

### 3.1 엑셀 수정

`GCP_GKE_Design` 시트에서 필요한 값을 수정합니다.

대표 수정값:

```text
Project ID     = 실제 GCP 프로젝트 ID
Region         = asia-northeast3 또는 원하는 region
Domain         = 실제 Google Workspace / Cloud Identity 도메인
Enabled        = 적용할 행만 TRUE
Machine Type   = e2-standard-2 등 비용/성능 기준으로 조정
Node Count     = 개인 테스트는 1 권장
```

### 3.2 CSV로 저장

엑셀에서 다음 형식으로 저장합니다.

```text
CSV UTF-8 (Comma delimited)
```

예시 파일명:

```text
gcp_gke_small_company_one_sheet_design.csv
```

### 3.3 tfvars 생성

```bash
python3 scripts/generate_tfvars_from_one_sheet_csv.py \
  --input gcp_gke_small_company_one_sheet_design.csv \
  --out-dir _generated
```

생성 예:

```text
_generated/10-network/sonmap.auto.tfvars
_generated/20-gke/sonmap.auto.tfvars
_generated/30-gke-rbac/sonmap.auto.tfvars
```

### 3.4 Terraform 적용

```bash
cp _generated/10-network/sonmap.auto.tfvars 10-network/sonmap.auto.tfvars
cd 10-network
terraform init
terraform plan
terraform apply

cd ../20-gke
cp ../_generated/20-gke/sonmap.auto.tfvars sonmap.auto.tfvars
terraform init
terraform plan
terraform apply

cd ../30-gke-rbac
cp ../_generated/30-gke-rbac/sonmap.auto.tfvars sonmap.auto.tfvars
terraform init
terraform plan
terraform apply
```

## 4. 주의

`sonmap.auto.tfvars`, `terraform.tfstate`, `tfplan`, kubeconfig, 서비스 계정 키 파일은 GitHub에 올리지 마세요.

Google Workspace / Cloud Identity 사용자와 그룹을 Terraform으로 직접 생성하려면 Admin SDK 권한과 도메인 위임 설정이 필요합니다. 개인 GCP 테스트에서는 그룹을 수동으로 생성하고 그룹 이메일만 엑셀에 넣어도 됩니다.
