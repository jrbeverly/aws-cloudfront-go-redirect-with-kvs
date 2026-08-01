#!/usr/bin/env bash
set -euo pipefail

KVS_ARN=$(terraform output -raw kvs_arn)
ETAG=$(aws cloudfront-keyvaluestore describe-key-value-store --kvs-arn "$KVS_ARN" --query ETag --output text)
aws cloudfront-keyvaluestore put-key --kvs-arn "$KVS_ARN" --key "$1" --value "$2" --if-match "$ETAG"
