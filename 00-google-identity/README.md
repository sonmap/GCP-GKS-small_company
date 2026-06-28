# 00-google-identity

Cloud Identity / Google Workspace 사용자, Google Group, 그룹 멤버십, Google Cloud IAM 권한을 설계하는 단계입니다.

실제 사용자/그룹 생성을 Terraform으로 자동화하려면 Google Workspace Admin SDK 권한과 도메인 위임 설정이 필요합니다. 개인 GCP 테스트에서는 그룹을 수동 생성한 뒤 `group_email` 값을 다음 단계에 넘기는 방식을 권장합니다.

대표 그룹:

| Group | Purpose |
|---|---|
| SG-GCP-PLATFORM-ADMINS | 프로젝트 관리자 |
| SG-GCP-SECURITY-OPS | 보안/로그 조회 |
| SG-GCP-GKE-OPERATORS | GKE 운영자 |
| SG-GCP-GKE-DEV-DEVELOPERS | 개발 Namespace 배포자 |
| SG-GCP-GKE-READERS | 조회자 |
