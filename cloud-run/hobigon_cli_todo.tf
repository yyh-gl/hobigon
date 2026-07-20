# 今日のタスク一覧のSlack通知バッチ（Notion連携）
module "hobigon_cli_todo" {
  source = "./modules/cloud_run_batch_job"

  project  = var.project
  location = var.region

  job_name = "hobigon-cli-todo"
  image    = "ghcr.io/yyh-gl/hobigon-golang-api-server/cli:v2.1.0"
  args     = ["notify-today-tasks"]

  cpu             = "1000m"
  memory          = "512Mi"
  max_retries     = 3
  timeout_seconds = 600

  service_account_email = google_service_account.batch_notifier.email
  deletion_protection   = var.deletion_protection

  secrets = [
    {
      env_name  = "NOTION_API_TOKEN"
      secret_id = "NOTION_API_TOKEN"
    },
    {
      env_name  = "NOTION_DATABASE_ID"
      secret_id = "NOTION_DATABASE_ID"
    },
    {
      env_name  = "WEBHOOK_URL_TO_00"
      secret_id = "WEBHOOK_URL_TO_00"
    }
  ]

  secret_values = {
    NOTION_API_TOKEN   = var.notion_api_token
    NOTION_DATABASE_ID = var.notion_database_id
    WEBHOOK_URL_TO_00  = var.webhook_url_to_00
  }

  schedule  = "0 7,12,19 * * *"
  time_zone = "Asia/Tokyo"

  depends_on = [time_sleep.wait_for_batch_notifier_iam]
}
