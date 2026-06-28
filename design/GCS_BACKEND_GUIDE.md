# Terraform State on GCS Backend

Terraform state 파일은 로컬 `terraform.tfstate` 대신 Google Cloud Storage bucket에 저장하는 방식을 권장합니다.

## 권장 구조

```text
gs://tfstate-<GCP_PROJECT_ID>-krc/
  gcp-gks-small-company/00-google-identity/default.tfstate
  gcp-gks-small-company/10-network/default.tfstate
  gcp-gks-small-company/20-gke/default.tfstate
  gcp-gks-small-company/30-gke-rbac/default.tfstate
```

## Bucket 생성

```bash
export PROJECT_ID="<GCP_PROJECT_ID>"
export TFSTATE_BUCKET="tfstate-${PROJECT_ID}-krc"
export TFSTATE_LOCATION="ASIA-NORTHEAST3"

./scripts/bootstrap_gcs_backend.sh
```

## 각 stack 적용

```bash
cd 10-network
cp backend.tf.example backend.tf
cp backend.hcl.example backend.hcl
vi backend.hcl
terraform init -backend-config=backend.hcl
```

이미 로컬 state가 있다면 다음처럼 GCS로 이전합니다.

```bash
terraform init -migrate-state -backend-config=backend.hcl
```

## 파일 관리

- `backend.tf.example`: Git에 보관하는 예제 파일
- `backend.hcl.example`: Git에 보관하는 예제 backend 설정
- `backend.tf`: 실제 적용용 로컬 파일
- `backend.hcl`: 실제 적용용 로컬 파일

실제 적용용 `backend.hcl`은 환경별 bucket/prefix가 들어가므로 Git에 올리지 않는 것을 권장합니다.
