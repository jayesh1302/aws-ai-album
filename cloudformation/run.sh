#!/bin/bash

CODEPIPELINE_STACK_NAME="frontend-codepipeline"
GITHUB_AUTH_TOKEN=${1}

if [ -z ${1} ]
then
	echo "PIPELINE CREATION FAILED!"
        echo "Pass your Github OAuth token as the first argument"
	exit 1
fi

set -eu

# check if the stack exists
if aws cloudformation describe-stacks --stack-name $CODEPIPELINE_STACK_NAME > /dev/null 2>&1
then
        echo "Updating existing stack..."
        aws cloudformation update-stack \
                --capabilities CAPABILITY_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=$GITHUB_AUTH_TOKEN \
                --template-body file://pipeline.yaml
else
        echo "Creating new stack..."
        aws cloudformation create-stack \
                --capabilities CAPABILITY_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=$GITHUB_AUTH_TOKEN \
                --template-body file://pipeline.yaml
fi