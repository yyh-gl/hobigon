variable "project" {
  type        = string
  description = "GCPプロジェクトID"
}

variable "location" {
  type        = string
  description = "Cloud Run Job / Cloud Schedulerのリージョン"
}

variable "job_name" {
  type        = string
  description = "Cloud Run Jobの名前"
}

variable "image" {
  type        = string
  description = "コンテナイメージ"
}

variable "args" {
  type        = list(string)
  description = "コンテナ起動引数"
  default     = []
}

variable "cpu" {
  type    = string
  default = "1000m"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "max_retries" {
  type    = number
  default = 3
}

variable "timeout_seconds" {
  type    = number
  default = 600
}

variable "service_account_email" {
  type        = string
  description = "Jobが使用するサービスアカウント"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "falseにするとterraform経由でのJob削除・置き換えを許可する。誤削除防止のため既定はtrue"
}

variable "secrets" {
  type = list(object({
    env_name  = string
    secret_id = string
    version   = optional(string, "latest")
  }))
  default     = []
  description = "Secret Managerから注入する環境変数一覧（値を除く）。secret_idごとにgoogle_secret_manager_secretとその初期バージョンを作成する"
}

variable "secret_values" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "secret_idをキーとした初期バージョンの値。初期作成後の値変更はignore_changesで無視するため、ローテーションはgcloud等で行う"
}

variable "plain_env" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "プレーンな環境変数一覧（秘密情報でないもの）"
}

variable "schedule" {
  type        = string
  description = "Cloud Schedulerのcron式"
}

variable "time_zone" {
  type    = string
  default = "Asia/Tokyo"
}
