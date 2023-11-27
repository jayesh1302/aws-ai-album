#!/bin/bash
GITHUB_AUTH_TOKEN=${1}

STACK_NAME_P1="P1"
STACK_NAME_P2="P2"
# create an array of stack names "P1" and "P2"
STACK_NAMES=($STACK_NAME_P1 $STACK_NAME_P2)

set -eu

# check if the flag -d presented, if so then delete the stack
if [ "$1" == "-d" ]; then
        echo "Deleting stack..."
        aws cloudformation delete-stack --stack-name $STACK_NAME_P1
        aws cloudformation delete-stack --stack-name $STACK_NAME_P2
        exit 0
else
        if [ -z ${1} ]; then
                echo "PIPELINE CREATION FAILED!"
                echo "Pass your Github OAuth token as the first argument"
                exit 1
        fi

        # loop through STACK_NAMES to check if the stack exists
        for STACK_NAME in "${STACK_NAMES[@]}"
        do
                if aws cloudformation describe-stacks --stack-name $STACK_NAME > /dev/null 2>&1
                then
                        echo "Updating existing stack..."
                        aws cloudformation update-stack \
                                --capabilities CAPABILITY_IAM \
                                --stack-name $STACK_NAME \
                                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=$GITHUB_AUTH_TOKEN \
                                --template-body file://${STACK_NAME}.yaml
                else
                        echo "Creating new stack..."
                        aws cloudformation create-stack \
                                --capabilities CAPABILITY_IAM \
                                --stack-name $STACK_NAME \
                                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=$GITHUB_AUTH_TOKEN \
                                --template-body file://${STACK_NAME}.yaml
                fi
        done
fi