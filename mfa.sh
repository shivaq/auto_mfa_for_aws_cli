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
MFA_ARN=$(grep "^$AWS_CLI_PROFILE" mfa.cfg | cut -d '=' -f 2- | tr -d '""')
# extract selected profile
SELECTED_PROFILE=$(grep "^$AWS_CLI_PROFILE" mfa.cfg | cut -d '=' -f -1 | tr -d '')

# check profile existence
if [ $SELECTED_PROFILE = $1 ]; then
    echo "profile $1 を使用します"
else
    echo "profile $1 は mfa.cfg 内に存在していません"
    return 1
fi

# check if given token is digits
rgx=^[0-9]+$
if ! [[ $MFA_TOKEN_CODE =~ $rgx ]]; then
    echo "トークンは数値のはずです。$MFA_TOKEN_CODE は数値ではありません"
    return 1
fi

# check the token length
if ! [ ${#MFA_TOKEN_CODE} -eq $NUM_OF_VALID_TOKENA ];then
    echo "トークン の長さが" ${#MFA_TOKEN_CODE} "文字です。 $NUM_OF_VALID_TOKENA 文字のトークンを使用してください。"
    return 1
fi

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $MFA_ARN"
echo "MFA Token Code: $MFA_TOKEN_CODE"

aws --profile $AWS_CLI_PROFILE sts get-session-token --duration 129600 \
    --serial-number $MFA_ARN --token-code $MFA_TOKEN_CODE --output text \
    | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACCESS_KEY=\"%s\"\nexport AWS_SESSION_TOKEN=\"%s\"\nexport AWS_SECURITY_TOKEN=\"%s\"\n",$2,$4,$5,$5)}' \
    | tee ~/.token_file=~~


# serverless framework will load ~/.aws/config
export AWS_SDK_LOAD_CONFIG=true
