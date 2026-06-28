#!/usr/bin/env python3
"""Generate Terraform tfvars from the one-sheet GCP/GKE design CSV.

Usage:
  python3 scripts/generate_tfvars_from_one_sheet_csv.py \
    --input gcp_gke_small_company_one_sheet_design.csv \
    --out-dir _generated

This script intentionally reads CSV, not XLSX. Edit the Excel workbook, save as
CSV UTF-8, then run this script.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Dict, Iterable, List


def truthy(value: str) -> bool:
    return str(value).strip().upper() in {"TRUE", "YES", "Y", "1"}


def q(value: str) -> str:
    value = str(value or "").replace('"', '\\"')
    return f'"{value}"'


def enabled_rows(rows: Iterable[Dict[str, str]]) -> List[Dict[str, str]]:
    return [r for r in rows if truthy(r.get("Enabled", ""))]


def first(rows: List[Dict[str, str]], resource_type: str) -> Dict[str, str] | None:
    for row in rows:
        if row.get("Resource Type") == resource_type:
            return row
    return None


def rows_by_type(rows: List[Dict[str, str]], resource_type: str) -> List[Dict[str, str]]:
    return [r for r in rows if r.get("Resource Type") == resource_type]


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"wrote {path}")


def generate_network(rows: List[Dict[str, str]]) -> str:
    vpc = first(rows, "VPC_NETWORK") or {}
    subnet = first(rows, "SUBNETWORK") or {}
    service_range = first(rows, "SUBNETWORK_SECONDARY_RANGE") or {}

    project_id = vpc.get("Project ID") or subnet.get("Project ID") or "<GCP_PROJECT_ID>"
    region = vpc.get("Region") or subnet.get("Region") or "asia-northeast3"
    name_prefix = (vpc.get("Name") or "vpc-ai-dev-krc").replace("vpc-", "", 1)

    return f'''# Generated from one-sheet Excel design. Do not commit real values.
project_id  = {q(project_id)}
region      = {q(region)}
name_prefix = {q(name_prefix)}

# Reference values from design
vpc_name              = {q(vpc.get("Name", "vpc-ai-dev-krc"))}
subnet_name           = {q(subnet.get("Subnetwork", subnet.get("Name", "snet-gke-ai-dev-krc")))}
subnet_primary_cidr   = {q(subnet.get("Primary CIDR", "10.40.0.0/20"))}
pods_range_name       = {q(subnet.get("Secondary Range Name", "pods"))}
pods_range_cidr       = {q(subnet.get("Secondary CIDR", "10.41.0.0/16"))}
services_range_name   = {q(service_range.get("Secondary Range Name", "services"))}
services_range_cidr   = {q(service_range.get("Secondary CIDR", "10.42.0.0/20"))}
'''


def generate_gke(rows: List[Dict[str, str]]) -> str:
    cluster = first(rows, "GKE_CLUSTER") or {}
    node_pool = first(rows, "GKE_NODE_POOL") or {}
    artifact = first(rows, "ARTIFACT_REGISTRY") or {}

    project_id = cluster.get("Project ID") or "<GCP_PROJECT_ID>"
    region = cluster.get("Region") or "asia-northeast3"

    return f'''# Generated from one-sheet Excel design. Do not commit real values.
project_id   = {q(project_id)}
region       = {q(region)}
cluster_name = {q(cluster.get("GKE Cluster Name", cluster.get("Name", "gke-ai-dev-krc")))}
network      = {q(cluster.get("Network", "vpc-ai-dev-krc"))}
subnetwork   = {q(cluster.get("Subnetwork", "snet-gke-ai-dev-krc"))}
machine_type = {q(node_pool.get("Machine Type", "e2-standard-2"))}

# Reference values from design
artifact_repository = {q(artifact.get("Artifact Repo", artifact.get("Name", "ar-ai-dev-krc")))}
node_pool_name      = {q(node_pool.get("Node Pool", node_pool.get("Name", "np-ai-user")))}
node_count          = {node_pool.get("Node Count") or 1}
min_nodes           = {node_pool.get("Min Nodes") or 1}
max_nodes           = {node_pool.get("Max Nodes") or 1}
disk_gb             = {node_pool.get("Disk GB") or 64}
'''


def generate_rbac(rows: List[Dict[str, str]]) -> str:
    rb = first(rows, "K8S_ROLE_BINDING") or {}
    cluster = first(rows, "GKE_CLUSTER") or {}
    project_id = cluster.get("Project ID") or rb.get("Project ID") or "<GCP_PROJECT_ID>"
    region = cluster.get("Region") or rb.get("Region") or "asia-northeast3"
    cluster_name = cluster.get("GKE Cluster Name") or cluster.get("Name") or "gke-ai-dev-krc"
    context = f"gke_{project_id}_{region}_{cluster_name}"

    return f'''# Generated from one-sheet Excel design. Do not commit real values.
kube_config_path    = "~/.kube/config"
kube_config_context = {q(context)}
developer_group_email = {q(rb.get("Subject Name", "sg-gcp-gke-dev-developers@example.com"))}
'''


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="One-sheet design CSV exported from Excel")
    parser.add_argument("--out-dir", default="_generated", help="Output directory")
    args = parser.parse_args()

    input_path = Path(args.input)
    out_dir = Path(args.out_dir)

    with input_path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        rows = enabled_rows(list(reader))

    if not rows:
        raise SystemExit("No enabled rows found. Check the Enabled column.")

    write(out_dir / "10-network" / "sonmap.auto.tfvars", generate_network(rows))
    write(out_dir / "20-gke" / "sonmap.auto.tfvars", generate_gke(rows))
    write(out_dir / "30-gke-rbac" / "sonmap.auto.tfvars", generate_rbac(rows))

    print("done")


if __name__ == "__main__":
    main()
