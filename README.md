# GCP GKE Small Company Lab

Azure `Entra ID + AKS` 실습 레포를 GCP 전용 구조로 변환한 Terraform 예제입니다.  
레포명은 요청에 맞춰 `GCP-GKS-small_company`로 두었지만, GCP의 Kubernetes 관리형 서비스 정식 명칭은 **GKE, Google Kubernetes Engine**입니다.

## 1. 목적

이 레포는 작은 회사 기준의 GCP/GKE 실습 환경을 단계별로 구성합니다.

- Google Workspace / Cloud Identity 사용자와 그룹 설계
- Google Cloud IAM 그룹 기반 권한 모델
- GKE용 VPC, Subnet, Pod/Service secondary range 구성
- GKE Standard Cluster, Node Pool, Artifact Registry 구성
- Kubernetes Namespace, Role, RoleBinding 구성

핵심 원칙은 다음입니다.

```text
Users -> Google Groups -> Google Cloud IAM -> GKE Cluster Access -> Kubernetes RBAC
```

사용자에게 직접 권한을 부여하지 않고, 그룹에 권한을 부여한 뒤 사용자를 그룹에 배치하는 구조입니다.

## 2. 전체 구성도

```mermaid
flowchart TB
    subgraph ID["00-google-identity\nCloud Identity / Google Workspace"]
        U["30 Users"]
        G["Google Groups"]
        GM["Group Memberships"]
        IAM["Google Cloud IAM\nProject-level roles"]
        U --> GM --> G --> IAM
    end

    subgraph NET["10-network\nGCP Network"]
        VPC["VPC\nvpc-ai-dev-krc"]
        S1["Subnet\nsnet-gke-system"]
        S2["Subnet\nsnet-gke-user"]
        SR["Secondary ranges\nPods / Services"]
        FW["Firewall rules"]
        VPC --> S1
        VPC --> S2
        S1 --> SR
        VPC --> FW
    end

    subgraph GKE["20-gke\nGoogle Kubernetes Engine"]
        AR["Artifact Registry"]
        SA["GKE Node Service Account"]
        CL["GKE Standard Cluster"]
        NP["User Node Pool"]
        AR --> CL
        SA --> CL
        CL --> NP
    end

    subgraph K8S["30-gke-rbac\nKubernetes RBAC"]
        NS1["Namespace ai-dev"]
        NS2["Namespace ai-test"]
        NS3["Namespace ai-prod"]
        RB["Role / RoleBinding"]
        NS1 --> RB
        NS2 --> RB
        NS3 --> RB
    end

    ID -. "Google Group email" .-> GKE
    IAM -. "container.* roles" .-> CL
    NET -. "VPC/Subnet" .-> CL
    GKE -. "kubeconfig" .-> K8S
```

## 3. Azure에서 GCP로 변환한 대응표

| Azure 원본 | GCP 변환 |
|---|---|
| Microsoft Entra ID User | Google Workspace / Cloud Identity User |
| Entra ID Security Group | Google Group |
| Azure RBAC | Google Cloud IAM |
| Azure VNet | GCP VPC Network |
| Azure Subnet | GCP Subnetwork |
| NSG | VPC Firewall Rule |
| AKS | GKE Standard Cluster |
| ACR | Artifact Registry Docker Repository |
| AKS Azure RBAC | Google Cloud IAM + GKE/Kubernetes RBAC |
| Kubernetes Namespace/RoleBinding | 동일하게 Kubernetes Provider 사용 |

## 4. 디렉터리 구조

```text
GCP-GKS-small_company/
├── 00-google-identity/
│   └── Google Workspace / Cloud Identity / IAM
├── 10-network/
│   └── VPC / Subnet / Firewall
├── 20-gke/
│   └── GKE / Node Pool / Artifact Registry
├── 30-gke-rbac/
│   └── Namespace / Role / RoleBinding
├── CONVERSION_MAP.md
└── README.md
```

## 5. 배포 순서

```bash
cd 00-google-identity
terraform init
terraform plan
terraform apply

cd ../10-network
terraform init
terraform plan
terraform apply

cd ../20-gke
terraform init
terraform plan
terraform apply

cd ../30-gke-rbac
terraform init
terraform plan
terraform apply
```

## 6. 사전 준비

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com
```

Google Workspace / Cloud Identity 그룹을 Terraform으로 관리하려면 Google Workspace Admin SDK 권한과 적절한 위임 설정이 필요합니다. 일반 GCP 프로젝트 IAM만 테스트하려면 `00-google-identity` 단계는 CSV 설계/수동 그룹 생성으로 대체할 수 있습니다.

## 7. 운영 보강 항목

- Terraform remote backend: GCS bucket 사용
- GKE private cluster 검토
- Cloud NAT / Private Google Access 검토
- Workload Identity Federation 적용
- Organization Policy, IAM Recommender, SCC 점검
- Cloud Logging / Monitoring / Alerting 연동
- 비용 예산 Budget Alert 설정
