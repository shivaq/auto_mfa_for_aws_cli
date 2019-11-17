# MFA トークンを簡単にセットする

## どのファイルをどこに格納するか

### ~ に格納するもの
* aws cli インストール時に 格納されているはず

~/.aws/credentials

~/.aws/config

* ディレクトリごと格納

~/auto_mfa_for_aws_cli

## 使い方

* MFA で取得した token code を使う
* フォーマット

`mfa <profile name> <token code>`

```bash
mfa serverless 012345
```


### スイッチロールをする場合

* --profile で指定するコマンド例
```bash
aws iam list-users --profile sls_admin_role
```

* serverless framework を使う場合は serverless.yml の下記にプロフィールを記載しておく
```yml
provider:
  profile: sls_admin_role
```

* 下記のように、そのロールのプロフィールが見つからないエラーが出力される場合

```bash
  Error: Profile sls_admin_role does not exist
```

* 下記を実行
```bash
export AWS_SDK_LOAD_CONFIG=true
```

-------------------------------------------------
## ユーザーの MFA の ARN の登録
### mfa.cfg の設定

* 各ユーザーの MFA の ARN を記載

```sh
my_name="arn:aws:iam::12345678987:mfa/yasuaki_shibata"
serverless="arn:aws:iam::12345678987:mfa/serverless_framework"
```

## aws cli を使うための環境設定

## MFA が必要なユーザーを登録しておく
### ~/.aws/credentials の設定

* IAMユーザーの各種キーをプロフィールとして登録


```ini
[my_name]
aws_access_key_id = AAAAAAAAP
aws_secret_access_key = AAAAAAAAP
[serverless]
aws_access_key_id = AAAAAAAAP
aws_secret_access_key = AAAAAAAAP
```


### ~/.aws/config の設定


* プロフィール と、それに紐づくデフォルトリージョンを指定

```ini
[profile my_name]
    region = ap-northeast-1
[profile serverless]
    region = ap-northeast-1
```



### スイッチロールをする場合

* ~/.aws/configに追記
* どのプロフィールから、どのロールにスイッチするか、そしてスイッチ後のプロフィール名の定義

* source_profile に指定した プロフィールの IAM ユーザーに、 role_arn のロールにスイッチする権限を付与しておく

```ini
[profile sls_admin_role]
    source_profile = serverless
    role_arn = arn:aws:iam::1234567890:role/Some_Role_In_An_Aws_Account

```
