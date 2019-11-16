#!/bin/bash

# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#
# Once the temp token is obtained, you'll need to feed the following environment
# variables to the aws-cli:
#
# export AWS_ACCESS_KEY_ID='KEY'
# export AWS_SECRET_ACCESS_KEY='SECRET'
# export AWS_SESSION_TOKEN='TOKEN'

NUM_OF_VALID_TOKENA=6
TEMP_FILE="sdkfjsldkfj_temp_file_dslkfjlskdflskdfjlskdjflsdjflskdjflskd"

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "引数は2つ必要です。もう一度やり直してください"
  echo "使い方: $0 <MFA_TOKEN_CODE> <AWS_CLI_PROFILE>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = virtual MFA device から取得したコード"
  echo "   <AWS_CLI_PROFILE> = aws-cli profile $HOME/.aws/config に記述されている"
  exit 1
fi

# Check config files
echo "mfa.cfg を読み込みます。。。"
if [ ! -r ~/auto_mfa_for_aws_cli/mfa.cfg ]; then
    echo "mfa.cfg がありません。作成しないとMFAセットできません"
    exit 1
fi

AWS_CLI_PROFILE=$1
MFA_TOKEN_CODE=$2

# extract iam ARN
MFA_ARN=$(grep "^$AWS_CLI_PROFILE" ~/auto_mfa_for_aws_cli/mfa.cfg | cut -d '=' -f 2- | tr -d '""')
# extract selected profile
SELECTED_PROFILE=$(grep "^$AWS_CLI_PROFILE" ~/auto_mfa_for_aws_cli/mfa.cfg | cut -d '=' -f -1 | tr -d '')

# check profile existence
if [ "$SELECTED_PROFILE" = $1 ]; then
    echo "profile $1 を使用します"
else
    echo "profile $1 は mfa.cfg 内に存在していません"
    exit 1
fi

# check if given token is digits
rgx=^[0-9]+$
if ! [[ $MFA_TOKEN_CODE =~ $rgx ]]; then
    echo "トークンは数値のはずです。$MFA_TOKEN_CODE は数値ではありません"
    exit 1
fi

# check the token length
if ! [ ${#MFA_TOKEN_CODE} -eq $NUM_OF_VALID_TOKENA ];then
    echo "トークン の長さが" ${#MFA_TOKEN_CODE} "文字です。 $NUM_OF_VALID_TOKENA 文字のトークンを使用してください。"
    exit 1
fi

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $MFA_ARN"
echo "MFA Token Code: $MFA_TOKEN_CODE"

# temp file to store succeeded outputs
touch $TEMP_FILE

# Try setting mfa token
aws --profile $AWS_CLI_PROFILE sts get-session-token --duration 129600 \
    --serial-number $MFA_ARN --token-code $MFA_TOKEN_CODE --output text \
    | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACCESS_KEY=\"%s\"\nexport AWS_SESSION_TOKEN=\"%s\"\nexport AWS_SECURITY_TOKEN=\"%s\"\n",$2,$4,$5,$5)}' \
    | tee ~/.token_file=~~ > $TEMP_FILE

# check if it's succeeded
if [ -s $TEMP_FILE ]; then
    source ~/.token_file
    echo "MFA トークンを設定しました"
    # serverless framework will load ~/.aws/config
    export AWS_SDK_LOAD_CONFIG=true
else
    echo "失敗"
fi


rm -f $TEMP_FILE