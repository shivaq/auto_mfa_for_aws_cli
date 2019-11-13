#!/bin/bash

# Usage
#  Add source ./<path of aliase.sh> to your ~/.bashrc

setToken(){
    ~/mfa.sh $1 $2
    if [ $? -ne 0 ]; then
        echo "MFA のトークンはセットできませんでした。"
    else
        source ~/.token_file
    fi
}

alias mfa=setToken

# Make serverless framework load ~/.aws/config
export AWS_SDK_LOAD_CONFIG=true