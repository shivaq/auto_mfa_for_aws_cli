# 環境設定

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


-------------------------------------------------
## ユーザーの MFA の ARN の登録
### mfa.cfg の設定

* 各ユーザーの MFA の ARN を記載

```sh
my_name="arn:aws:iam::750747051508:mfa/yasuaki_shibata"
serverless="arn:aws:iam::750747051508:mfa/serverless_framework"
```

# どのファイルをどこに格納するか

### ~ に格納
* aws cli インストール時に 格納されているはず

~/.aws/credentials

~/.aws/config

### 2つのファイルを同じパスに格納
* 任意の場所でよい

mfa.cfg

set_mfa_token.sh


# 使い方

* token code は MFA で取得したもの
* set_mfa_token.sh のあるパスで実行
* フォーマット
`set_mfa_token.sh <profile name> <token code>`

```bash
set_mfa_token.sh serverless 012345
```


## スイッチロールをする場合

* --profile で
```bash
aws iam list-users --profile sls_admin_role
```