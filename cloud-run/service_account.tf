# Cloud Run Job形式の通知バッチが共通で使用するサービスアカウント。
# ジョブごとに分離せず1つに集約する方針（docs/plans/2026-07-20-cloud-run-job-terraform-migration.md 決定事項2）。
resource "google_service_account" "batch_notifier" {
  project      = var.project
  account_id   = "hobigon-batch-notifier"
  display_name = "Hobigon batch notifier"
  description  = "Cloud Run Job形式の通知バッチが共通で使用するサービスアカウント"
}

resource "google_project_iam_member" "batch_notifier_secret_accessor" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.batch_notifier.email}"
}

resource "google_project_iam_member" "batch_notifier_run_invoker" {
  project = var.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.batch_notifier.email}"
}

# IAM権限の付与はAPI呼び出しが成功した後もGCP内部への伝播にラグがあり、
# 直後にこのSAを使うリソースを作成すると Permission denied になることがあるため明示的に待つ。
resource "time_sleep" "wait_for_batch_notifier_iam" {
  create_duration = "30s"

  depends_on = [
    google_project_iam_member.batch_notifier_secret_accessor,
    google_project_iam_member.batch_notifier_run_invoker,
  ]
}
