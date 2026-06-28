# Azure to GCP Conversion Map

| Area | Azure | GCP |
|---|---|---|
| Identity | Microsoft Entra ID | Google Workspace / Cloud Identity |
| User | `azuread_user` | `googleworkspace_user` 또는 수동/SCIM 연동 |
| Group | `azuread_group` | `googleworkspace_group` / Google Group |
| Group Membership | `azuread_group_member` | `googleworkspace_group_member` |
| Cloud IAM | `azurerm_role_assignment` | `google_project_iam_member` |
| Network | Azure VNet | Google Compute VPC |
| Subnet | Azure Subnet | Google Compute Subnetwork |
| Security Rules | NSG / NSG Rule | VPC Firewall Rule |
| Kubernetes | AKS | GKE Standard / Autopilot |
| Container Registry | ACR | Artifact Registry |
| Monitoring | Log Analytics | Cloud Logging / Cloud Monitoring |
| Cluster RBAC | AKS Azure RBAC | Google Cloud IAM + Kubernetes RBAC |

## 권장 변환 방향

Azure AKS 실습은 `Entra Group -> Azure RBAC -> AKS Azure RBAC -> Kubernetes RBAC` 구조였습니다.  
GCP에서는 `Google Group -> Google Cloud IAM -> GKE access -> Kubernetes RBAC` 구조로 설계합니다.

주의: GCP에는 AKS Azure RBAC와 완전히 동일한 단일 기능이 없습니다. GKE 접근은 Google Cloud IAM으로 제어하고, Namespace 단위 작업 권한은 Kubernetes RBAC로 나누는 방식이 적합합니다.
