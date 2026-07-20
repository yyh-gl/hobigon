resource "google_secret_manager_secret" "this" {
  for_each  = { for s in var.secrets : s.secret_id => s }
  project   = var.project
  secret_id = each.value.secret_id

  replication {
    auto {}
  }
}

# 初回作成時にJobがすぐ参照できるよう初期バージョンをTerraformで作成する。
# 作成後のローテーションはgcloud等で手動運用するため、以降の値変更はTerraformの差分として検知しない。
resource "google_secret_manager_secret_version" "this" {
  for_each    = { for s in var.secrets : s.secret_id => s }
  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = var.secret_values[each.key]

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_cloud_run_v2_job" "this" {
  name                = var.job_name
  project             = var.project
  location            = var.location
  deletion_protection = var.deletion_protection

  # secret_key_ref(version = "latest")の解決に必要なため、初期バージョン作成を待つ
  depends_on = [google_secret_manager_secret_version.this]

  template {
    template {
      containers {
        image = var.image
        args  = var.args

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        dynamic "env" {
          for_each = var.secrets
          content {
            name = env.value.env_name
            value_source {
              secret_key_ref {
                secret  = google_secret_manager_secret.this[env.value.secret_id].secret_id
                version = env.value.version
              }
            }
          }
        }

        dynamic "env" {
          for_each = var.plain_env
          content {
            name  = env.value.name
            value = env.value.value
          }
        }
      }

      max_retries = var.max_retries
      timeout     = "${var.timeout_seconds}s"
      service_account = var.service_account_email
    }
  }
}

# Cloud Run Jobs自体にはスケジュール実行の概念がないため、Cloud Scheduler経由でRun Admin APIのjobs.runを叩く。
resource "google_cloud_scheduler_job" "this" {
  name      = "${var.job_name}-trigger"
  project   = var.project
  region    = var.location
  schedule  = var.schedule
  time_zone = var.time_zone

  http_target {
    http_method = "POST"
    uri         = "https://${var.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/${var.job_name}:run"

    oauth_token {
      service_account_email = var.service_account_email
    }
  }

  depends_on = [google_cloud_run_v2_job.this]
}
