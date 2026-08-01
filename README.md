# Go redirects with CloudFront KeyValueStore

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

Tests whether a CloudFront distribution can serve go-link style redirects (`/<key>` → 302) entirely at the edge using a CloudFront Function and KeyValueStore, with no origin request and no Lambda.

```sh
terraform init && terraform apply
./put-key.sh <key> <url>
curl -sI "https://$(terraform output -raw cloudfront_domain)/docs"
aws s3 rm "s3://$(terraform output -raw bucket_name)" --recursive && terraform destroy
```

## Notes

- Straightforward experiment, little unexpected
- Confirms original assumption that certificate-driven access flow works for an APT mirror
- Potentially useful as lightweight external mirror
- Potentially useful for self-hosted package distribution
- Potentially useful for internal package repositories
- Useful anywhere controlled package access needs to remain simple
- Particularly relevant for Packer build flows
- Enables packages / tools to be pulled during machine-image construction
- Supports pre-baking required tooling directly into machine images
- Could provide controlled package source for repeatable image builds
