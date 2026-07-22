variable "project" {
  type        = string
  description = "GCPプロジェクトID"
}

variable "region" {
  type        = string
  description = "デフォルトのGCPリージョン"
  default     = "asia-northeast1"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "falseにするとCloud Run Jobのterraform経由での削除・置き換えを許可する。作業をリセットしたい時だけ `-var=\"deletion_protection=false\"` で一時的に上書きする"
}

variable "son_line_bot_channel_access_token" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-coopが使用するLINE Messaging APIのチャネルアクセストークン。terraform.tfvarsで設定する"
}

variable "webhook_url_to_03" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-pokemonが使用するSlack Webhook URL。terraform.tfvarsで設定する"
}

variable "notion_api_token" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-todoが使用するNotion APIトークン。terraform.tfvarsで設定する"
}

variable "notion_database_id" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-todoが使用するNotionデータベースID。terraform.tfvarsで設定する"
}

variable "webhook_url_to_00" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-todoが使用するSlack Webhook URL。terraform.tfvarsで設定する"
}
