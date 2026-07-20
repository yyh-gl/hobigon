# 生鮮館の入金リマインダーのLINE通知バッチ
module "hobigon_cli_seisenkan" {
  source = "./modules/cloud_run_batch_job"

  project  = var.project
  location = var.region

  job_name = "hobigon-cli-seisenkan"
  image    = "ghcr.io/yyh-gl/hobigon-golang-api-server/cli:v2.1.0"
  args     = ["notify-seisenkan-payment-reminder"]

  cpu             = "1000m"
  memory          = "512Mi"
  max_retries     = 3
  timeout_seconds = 600

  service_account_email = google_service_account.batch_notifier.email
  deletion_protection   = var.deletion_protection

  # LINE_CHANNEL_ACCESS_TOKENはhobigon-cli-coopと同一のLINE公式アカウントのトークンを共用するため、
  # 新規作成せずhobigon-cli-coopが作成済みのシークレットを参照する。
  existing_secrets = [
    {
      env_name  = "LINE_CHANNEL_ACCESS_TOKEN"
      secret_id = module.hobigon_cli_coop.secret_ids["LINE_CHANNEL_ACCESS_TOKEN"]
    }
  ]

  schedule  = "0 9,12 5,15,25 * *"
  time_zone = "Asia/Tokyo"

  depends_on = [time_sleep.wait_for_batch_notifier_iam]
}
