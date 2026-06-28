# GCP GKE One Sheet Excel Detailed Specification

이 문서는 `GCP_GKE_Design` 엑셀 1장에 들어가는 전체 설계 항목을 쉽게 설명합니다.

## 1. 엑셀 설계 목적

이 엑셀은 GCP/GKE 소규모 회사 실습 환경을 코드 적용 전에 먼저 설계하기 위한 입력 원장입니다.

흐름은 다음과 같습니다.

```text
Excel 1 Sheet
  -> CSV UTF-8 저장
  -> scripts/generate_tfvars_from_one_sheet_csv.py 실행
  -> _generated/*/sonmap.auto.tfvars 생성
  -> Terraform plan/apply
```

## 2. 한 시트 원칙

시트 이름은 `GCP_GKE_Design` 하나만 사용합니다.

여러 시트로 나누지 않고 모든 리소스를 한 표에 넣는 이유는 다음과 같습니다.

- 필터로 `Section`별 확인 가능
- 필터로 `Resource Type`별 확인 가능
- `Enabled=TRUE/FALSE`로 적용 대상 제어 가능
- `Apply Order`로 적용 순서 관리 가능
- `Depends On`으로 리소스 선후 관계 확인 가능
- Terraform 변환 스크립트가 한 파일만 읽으면 됨

## 3. 주요 컬럼 설명

| Column | 쉬운 설명 | 예시 |
|---|---|---|
| `No` | 행 번호 | `1` |
| `Enabled` | 적용 여부. TRUE만 적용 대상으로 사용 | `TRUE` |
| `Section` | 적용 단계 | `10-network` |
| `Resource Type` | 리소스 종류 | `GKE_CLUSTER` |
| `Apply Order` | 적용 순서 | `620` |
| `Resource Key` | 행을 식별하는 고유 키 | `gke-ai-dev-krc` |
| `Name` | 리소스 이름 | `gke-ai-dev-krc` |
| `설계 설명(쉽게)` | 이 행이 왜 필요한지 설명 | `GKE Standard Cluster입니다` |
| `사용자가 수정할 값` | 사용자가 바꿔야 하는 컬럼 안내 | `Project ID, Region` |
| `필수 여부` | 필수인지 선택인지 | `Y`, `Optional` |
| `Depends On` | 먼저 있어야 하는 리소스 | `snet-gke-ai-dev-krc` |
| `Project ID` | 실제 GCP 프로젝트 ID | `my-gcp-project` |
| `Region` | GCP Region | `asia-northeast3` |
| `Zone` | GCP Zone | `asia-northeast3-a` |
| `Domain` | Google Workspace/Cloud Identity 도메인 | `example.com` |
| `Generated File` | 변환 후 생성될 파일 | `_generated/20-gke/sonmap.auto.tfvars` |
| `Terraform Variable` | Terraform 변수명 | `cluster_name` |
| `Example Value` | 예시값 | `gke-ai-dev-krc` |
| `운영 메모` | 운영 시 주의사항 | `운영은 private cluster 검토` |

## 4. Section별 의미

### 4.1 `00-google-identity`

Google Workspace / Cloud Identity / IAM 설계 영역입니다.

포함 리소스:

| Resource Type | 설명 |
|---|---|
| `PROJECT_SERVICE` | GCP API 활성화 |
| `IDENTITY_USER` | 사용자 설계 |
| `IDENTITY_GROUP` | Google Group 설계 |
| `GROUP_MEMBERSHIP` | 사용자/그룹 멤버십 설계 |
| `PROJECT_IAM` | Google Cloud IAM 권한 설계 |

중요 포인트:

- 사용자는 직접 권한을 받지 않습니다.
- 사용자를 Google Group에 넣습니다.
- Google Group에 IAM 권한을 부여합니다.
- GKE Namespace 권한도 Google Group email을 기준으로 RoleBinding합니다.

권한 흐름:

```text
User -> Google Group -> Google Cloud IAM -> GKE / Kubernetes RBAC
```

### 4.2 `10-network`

GKE가 사용할 네트워크 영역입니다.

포함 리소스:

| Resource Type | 설명 |
|---|---|
| `VPC_NETWORK` | GCP VPC. Azure VNet에 해당 |
| `SUBNETWORK` | GKE 노드가 들어갈 Subnet |
| `SUBNETWORK_SECONDARY_RANGE` | GKE Pod/Service IP 대역 |
| `FIREWALL_RULE` | VPC Firewall Rule. Azure NSG와 비슷한 역할 |

기본 CIDR 예시:

| 용도 | CIDR |
|---|---|
| Node subnet | `10.40.0.0/20` |
| Pod secondary range | `10.41.0.0/16` |
| Service secondary range | `10.42.0.0/20` |

### 4.3 `20-gke`

Google Kubernetes Engine 영역입니다.

포함 리소스:

| Resource Type | 설명 |
|---|---|
| `ARTIFACT_REGISTRY` | Docker 이미지 저장소. Azure ACR에 해당 |
| `SERVICE_ACCOUNT` | GKE Node Pool용 서비스 계정 |
| `GKE_CLUSTER` | GKE Standard Cluster |
| `GKE_NODE_POOL` | 사용자 workload용 Node Pool |

개인 테스트 기본값:

| 항목 | 값 |
|---|---|
| Cluster | `gke-ai-dev-krc` |
| Node Pool | `np-ai-user` |
| Machine Type | `e2-standard-2` |
| Node Count | `1` |
| Disk GB | `64` |
| Workload Identity | `TRUE` |
| Private Cluster | `FALSE` |

운영에서는 `Private Cluster=TRUE`, Cloud NAT, Bastion 또는 내부 접근 경로를 함께 검토해야 합니다.

### 4.4 `30-gke-rbac`

Kubernetes Namespace와 RBAC 영역입니다.

포함 리소스:

| Resource Type | 설명 |
|---|---|
| `K8S_NAMESPACE` | `ai-dev`, `ai-test`, `ai-prod` 등 namespace |
| `K8S_ROLE` | namespace 내부 권한 정의 |
| `K8S_ROLE_BINDING` | Google Group email과 Role 연결 |

예시 RoleBinding:

| Namespace | Role | Group |
|---|---|---|
| `ai-dev` | `ai-developer` | `sg-gcp-gke-dev-developers@example.com` |
| `ai-test` | `ai-developer` | `sg-gcp-gke-dev-developers@example.com` |
| `ai-prod` | `ai-reader` | `sg-gcp-gke-readers@example.com` |
| `ai-prod` | `ai-reader` | `sg-gcp-security-ops@example.com` |

## 5. 사용자가 실제로 수정해야 할 값

처음 테스트 시에는 아래 값만 실제 환경에 맞게 수정해도 됩니다.

| 변경 대상 | 설명 |
|---|---|
| `Project ID` | 실제 GCP 프로젝트 ID |
| `Domain` | 실제 Google Workspace / Cloud Identity 도메인 |
| `Group Email` | 실제 Google Group email |
| `Region` | 기본은 `asia-northeast3` |
| `Machine Type` | 비용에 맞게 `e2-standard-2`, `e2-medium` 등 선택 |
| `Node Count` | 개인 테스트는 `1` 권장 |
| `Primary CIDR` | 회사/온프레 CIDR와 중복되지 않게 수정 |
| `Pods CIDR` | GKE Pod 대역 |
| `Services CIDR` | Kubernetes Service 대역 |

## 6. 적용 방법

엑셀 수정 후 CSV UTF-8로 저장합니다.

```bash
python3 scripts/generate_tfvars_from_one_sheet_csv.py \
  --input GCP_GKE_OneSheet_Detailed_Design.csv \
  --out-dir _generated
```

생성 파일:

```text
_generated/10-network/sonmap.auto.tfvars
_generated/20-gke/sonmap.auto.tfvars
_generated/30-gke-rbac/sonmap.auto.tfvars
```

Terraform 적용:

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

## 7. 보안 주의

아래 파일은 GitHub에 올리지 않습니다.

```text
terraform.tfstate
terraform.tfstate.backup
tfplan
sonmap.auto.tfvars
credentials*.json
*-key.json
kubeconfig
.kube/
```

엑셀에는 실제 비밀번호, 서비스 계정 키, access token, kubeconfig 내용을 넣지 마세요.
