output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "cluster_location" {
  value = google_container_cluster.cluster.location
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --region ${google_container_cluster.cluster.location} --project ${var.project_id}"
}
