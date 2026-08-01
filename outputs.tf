output "cloudfront_domain" {
  value = aws_cloudfront_distribution.redirects.domain_name
}

output "kvs_arn" {
  value = aws_cloudfront_key_value_store.redirects.arn
}

output "bucket_name" {
  value = aws_s3_bucket.origin.id
}
