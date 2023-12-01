# aws-ai-album
Assignment 3 for Cloud-Computing-AWS-CSGY-9223

## How to deploy

```bash
export AWS_DEFAULT_PROFILE=terraform
export AWS_DEFAULT_REGION=us-east-1
./cloudformation/run.sh <GITHUB_TOKEN_1> <GITHUB_TOKEN_2>
```

P1 stack
- OpenSearch
- P1 -> P1_LF (LF1 LF2)

P2 stack (P2, B1)
- Api stack [depends_on: P1] (ApiGateway [LF2], B2)

(optional?)
git changes
- add SDK1 to frontend
- add OpenSearch URL to LF1