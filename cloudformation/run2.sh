#!/bin/bash

STACK_NAMES=("apiGateway")
BUCKET_NAMES=("b2-bucket-11-26")

if [ "$1" == "-d" ]; then
        # loop through BUCKET_NAMES and delete the bucket
        for BUCKET_NAME in "${BUCKET_NAMES[@]}"
        do
                echo "Deleting bucket...${BUCKET_NAME}"
                # try and catch to delete all objects in the bucket
                aws s3api delete-objects --bucket $BUCKET_NAME  --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" || echo "no version"
                # if the bucket is not empty, then delete all objects in the bucket
                aws s3 rm s3://$BUCKET_NAME --recursive || echo "no object"
                # if the bucket is empty, then delete the bucket
                aws s3 rb s3://$BUCKET_NAME --force || echo "no bucket"
        done
        for STACK_NAME in "${STACK_NAMES[@]}"
        do
                echo "Deleting stack...${STACK_NAME}"
                aws cloudformation delete-stack --stack-name $STACK_NAME
        done
        exit 0
else
        # loop through STACK_NAMES to check if the stack exists
        for idx in "${!STACK_NAMES[@]}"
        do
                if aws cloudformation describe-stacks --stack-name ${STACK_NAMES[$idx]} > /dev/null 2>&1
                then
                        echo "Updating existing stack..."
                        aws cloudformation update-stack \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --stack-name ${STACK_NAMES[$idx]} \
                                --template-body file://${STACK_NAMES[$idx]}.yaml
                else
                        echo "Creating new stack..."
                        aws cloudformation create-stack \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --stack-name ${STACK_NAMES[$idx]} \
                                --template-body file://${STACK_NAMES[$idx]}.yaml
                fi
        done
fi