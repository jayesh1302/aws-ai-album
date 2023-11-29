#!/bin/bash

STACK_NAMES=("Test")

for idx in "${!STACK_NAMES[@]}"
do
    if aws cloudformation describe-stacks --stack-name ${STACK_NAMES[$idx]} > /dev/null 2>&1
    then
            echo "Updating existing stack..."
            aws cloudformation update-stack \
                    --capabilities CAPABILITY_IAM \
                    --stack-name ${STACK_NAMES[$idx]} \
                    --template-body file://${STACK_NAMES[$idx]}.yaml
    else
            echo "Creating new stack..."
            aws cloudformation create-stack \
                    --capabilities CAPABILITY_IAM \
                    --stack-name ${STACK_NAMES[$idx]} \
                    --template-body file://${STACK_NAMES[$idx]}.yaml
    fi
done