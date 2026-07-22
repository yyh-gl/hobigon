# 生協支払いリマインダーのLINE通知バッチ
module "hobigon_cli_coop" {
  source = "./modules/cloud_run_batch_job"

  project  = var.project
  location = var.region

  job_name = "hobigon-cli-coop"
  image    = "ghcr.io/yyh-gl/hobigon-golang-api-server/cli:v3.0.0"
  args     = ["notify-to-line --bot-key=son --message-key=coop"]

  cpu             = "1000m"
  memory          = "512Mi"
  max_retries     = 3
  timeout_seconds = 600

  service_account_email = google_service_account.batch_notifier.email
  deletion_protection   = var.deletion_protection

  secrets = [
    {
      env_name  = "LINE_CHANNEL_ACCESS_TOKEN"
      secret_id = "LINE_CHANNEL_ACCESS_TOKEN"
    }
  ]

  secret_values = {
    LINE_CHANNEL_ACCESS_TOKEN = var.line_channel_access_token
  }

  schedule  = "0 9,12 1,5,15,25 * *"
  time_zone = "Asia/Tokyo"

  depends_on = [time_sleep.wait_for_batch_notifier_iam]
}
