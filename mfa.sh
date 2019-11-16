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

AWS_CLI=`which aws`

# Check aws cli existence
if [ $? -ne 0 ]; then
    echo "AWS CLI がインストールされていません。シェルを終了します"
    return 1
else
    echo "$AWS_CLI にある AWS CLI を今から利用します"
fi

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "引数は2つ必要です。もう一度やり直してください"
  echo "使い方: $0 <MFA_TOKEN_CODE> <AWS_CLI_PROFILE>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = virtual MFA device から取得したコード"
  echo "   <AWS_CLI_PROFILE> = aws-cli profile $HOME/.aws/config に記述されている"
  return 1
fi

# Check config files
echo "mfa.cfg を読み込みます。。。"
if [ ! -r mfa.cfg ]; then
    echo "mfa.cfg がありません。作成しないとMFAセットできません"
    return 1
fi

AWS_CLI_PROFILE=$1
MFA_TOKEN_CODE=$2
# extract iam ARN
ARN_OF_MFA=$(grep "^$AWS_CLI_PROFILE" mfa.cfg | cut -d '=' -f 2- | tr -d '""')

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $ARN_OF_MFA"
echo "MFA Token Code: $MFA_TOKEN_CODE"

if [ -z "$ARN_OF_MFA" ]; then
    echo "profile $AWS_CLI_PROFILE は設定されていません"
    return 1
else
    cp ~/.token_file ~/.token_file.bak
    aws --profile $AWS_CLI_PROFILE sts get-session-token --duration 129600 \
      --serial-number $ARN_OF_MFA --token-code $MFA_TOKEN_CODE --output text \
      | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACCESS_KEY=\"%s\"\nexport AWS_SESSION_TOKEN=\"%s\"\nexport AWS_SECURITY_TOKEN=\"%s\"\n",$2,$4,$5,$5)}' | tee ~/.token_file=~~
fi