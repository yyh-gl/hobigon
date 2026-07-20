output "job_name" {
  value = google_cloud_run_v2_job.this.name
}

output "scheduler_job_name" {
  value = google_cloud_scheduler_job.this.name
}

output "secret_ids" {
  value       = { for s in var.secrets : s.secret_id => google_secret_manager_secret.this[s.secret_id].secret_id }
  description = "secret_idをキーとした作成済みSecret Managerシークレットのsecret_idマップ。他Jobからexisting_secretsで参照する用"
  depends_on  = [google_secret_manager_secret_version.this]
}
