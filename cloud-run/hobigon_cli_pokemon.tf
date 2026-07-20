# ポケモンカードのイベント情報のSlack通知バッチ
module "hobigon_cli_pokemon" {
  source = "./modules/cloud_run_batch_job"

  project  = var.project
  location = var.region

  job_name = "hobigon-cli-pokemon"
  image    = "ghcr.io/yyh-gl/hobigon-golang-api-server/cli:v2.1.0"
  args     = ["notify-pokemon-event"]

  cpu             = "1000m"
  memory          = "512Mi"
  max_retries     = 3
  timeout_seconds = 600

  service_account_email = google_service_account.batch_notifier.email
  deletion_protection   = var.deletion_protection

  secrets = [
    {
      env_name  = "WEBHOOK_URL_TO_03"
      secret_id = "WEBHOOK_URL_TO_03"
    }
  ]

  secret_values = {
    WEBHOOK_URL_TO_03 = var.webhook_url_to_03
  }

  schedule  = "0 12 * * *"
  time_zone = "Asia/Tokyo"

  depends_on = [time_sleep.wait_for_batch_notifier_iam]
}
