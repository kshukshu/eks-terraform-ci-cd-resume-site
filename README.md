# cloud-resume-eks
## ファイル構成と主な役割

.
├── provider.tf # AWS/Kubernetesのプロバイダー設定
│ # 使用するプロファイルやkubeconfigを指定
│
├── variables.tf # 再利用可能な変数定義
│ # リージョンやサブネットIDのパラメータ化
│
├── main.tf # IAMユーザー・IAMロール・EKSクラスターの構築
│ # インフラの本体定義
│
├── aws_auth.tf # aws-auth ConfigMap の構成
│ # EKSへのアクセス許可を管理
│
├── outputs.tf # アクセスキーなどの出力
│ # infra-admin のAWSキー確認など