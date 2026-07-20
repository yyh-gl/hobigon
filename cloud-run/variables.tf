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

variable "line_channel_access_token" {
  type        = string
  sensitive   = true
  description = "hobigon-cli-coopが使用するLINE Messaging APIのチャネルアクセストークン。terraform.tfvarsで設定する"
}
