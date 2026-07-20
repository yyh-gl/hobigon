# cloud-run/ 適用手順書

GCP Cloud Run Job（`hobigon-cli-coop`）をこのTerraformコードで管理するための、初回適用手順。

既存リソースは削除してからTerraformで作り直す方針のため、**この手順の実行中は`hobigon-cli-coop`によるLINE通知が一時的に止まる**。

## 前提条件

- `terraform` CLI（1.9以上）がインストール済みであること
- `gcloud` CLIがインストール済みで、対象プロジェクト（`hobby-228117`）への十分な権限（Cloud Run管理者・Cloud Scheduler管理者・Secret Manager管理者・IAM管理者相当）を持つアカウントでログイン済みであること
- 以下でTerraformが使うApplication Default Credentialsを設定済みであること

```bash
gcloud auth application-default login
```

## Step 1. 既存シークレット値の退避

作り直し後に再登録するため、現行の`LINE_CHANNEL_ACCESS_TOKEN`の値を確認して控える。

```bash
gcloud secrets versions access latest \
  --secret=LINE_CHANNEL_ACCESS_TOKEN \
  --project=hobby-228117
```

出力された値は、後ほどStep3で`terraform.tfvars`に設定するために使う。パスワードマネージャーなど安全な場所に一時保存する。

## Step 2. 既存リソースの手動削除

対象を確認してから削除する。

```bash
# Cloud Run Jobの確認・削除
gcloud run jobs describe hobigon-cli-coop --region=asia-northeast1 --project=hobby-228117
gcloud run jobs delete hobigon-cli-coop --region=asia-northeast1 --project=hobby-228117

# Cloud Schedulerジョブの確認・削除（ジョブ名は一覧から確認する）
gcloud scheduler jobs list --location=asia-northeast1 --project=hobby-228117
gcloud scheduler jobs delete <上記で確認したジョブ名> --location=asia-northeast1 --project=hobby-228117

# Secret Managerシークレットの確認・削除
gcloud secrets describe LINE_CHANNEL_ACCESS_TOKEN --project=hobby-228117
gcloud secrets delete LINE_CHANNEL_ACCESS_TOKEN --project=hobby-228117
```

いずれもコンソール（Cloud Run / Cloud Scheduler / Secret Manager の各画面）から削除しても構わない。

## Step 3. `terraform.tfvars`の設定

`cloud-run/terraform.tfvars`（Git管理外）に以下が設定済みであることを確認する。未作成の場合は`terraform.tfvars.example`をコピーして値を埋める。`line_channel_access_token`にはStep1で控えた値を設定する。

```bash
cp terraform.tfvars.example terraform.tfvars
# project, region, line_channel_access_token を編集
```

`line_channel_access_token`はSecret Managerの初期バージョンとしてTerraformが登録するため、tfstateファイル（`cloud-run/terraform.tfstate`、Git管理外）に平文で保存される点に注意する。作成後のローテーションはTerraformでは追跡しないため、`gcloud secrets versions add`等で直接行う。

## Step 4. Terraformの実行

Secretの作成・初期バージョン登録・Cloud Run Job・Cloud Schedulerまで1回のapplyで完結する。

```bash
cd cloud-run
terraform init
terraform validate
terraform plan
```

`plan`の出力で、以下がすべて**新規作成**として表示されることを確認する。既存リソースとの重複エラーが出た場合はStep2の削除漏れなので、削除してから再実行する。

- `google_service_account.batch_notifier`
- `google_project_iam_member.batch_notifier_secret_accessor`
- `google_project_iam_member.batch_notifier_run_invoker`
- `time_sleep.wait_for_batch_notifier_iam`
- `module.hobigon_cli_coop.google_secret_manager_secret.this["LINE_CHANNEL_ACCESS_TOKEN"]`
- `module.hobigon_cli_coop.google_secret_manager_secret_version.this["LINE_CHANNEL_ACCESS_TOKEN"]`
- `module.hobigon_cli_coop.google_cloud_run_v2_job.this`
- `module.hobigon_cli_coop.google_cloud_scheduler_job.this`

問題なければ適用する。

```bash
terraform apply
```

## Step 5. 動作確認

Jobを手動実行し、LINEに通知が届くこと・実行が成功することを確認する。

```bash
gcloud run jobs execute hobigon-cli-coop --region=asia-northeast1 --project=hobby-228117

# 実行結果の確認
gcloud run jobs executions list \
  --job=hobigon-cli-coop \
  --region=asia-northeast1 \
  --project=hobby-228117
```

`completionStatus`が`EXECUTION_SUCCEEDED`になっていること、LINEに通知メッセージが届いていることの両方を確認する。

また、Cloud Schedulerからの起動経路も確認したい場合は、コンソールのCloud Schedulerページから該当ジョブの「今すぐ実行」を押して同様に確認する。

## Step 6. 後片付け

動作確認が完了したら、参考資料として残っていた`example.yaml`をリポジトリから削除する。

```bash
git rm example.yaml
```

## 作業を最初からやり直したい場合（リセット手順）

適用途中でエラーになり、Terraform管理下のリソースを一旦すべて消して最初からやり直したいときの手順。

`google_cloud_run_v2_job`は誤削除防止のため`deletion_protection = true`が既定になっており、通常の`terraform destroy`は拒否される。リセット時だけ`-var`で一時的に無効化する。

```bash
cd cloud-run
terraform destroy -var="deletion_protection=false"
```

`terraform state list`で何も出力されなければリセット完了。以降は本手順のStep3（`terraform.tfvars`が既にあるなら）またはStep1から再開する。`deletion_protection`はコード上ずっと`true`のままなので、この`-var`指定はdestroy実行時のみ有効で、以降のapplyには影響しない。

なお、Secret Managerのシークレットも同時に削除されるため、直後に同名で作り直すと数十秒〜数分ほど反映にラグが出ることがある。`terraform apply`で`Secret already exists`のようなエラーが出た場合は、少し待ってから再実行する。
