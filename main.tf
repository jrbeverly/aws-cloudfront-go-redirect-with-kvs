resource "aws_cloudfront_key_value_store" "redirects" {
  name = "go-redirects"
}

resource "terraform_data" "seed_keys" {
  triggers_replace = [aws_cloudfront_key_value_store.redirects.arn]

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      KVS_ARN="${aws_cloudfront_key_value_store.redirects.arn}"

      ETAG=$(aws cloudfront-keyvaluestore describe-key-value-store --kvs-arn "$KVS_ARN" --query ETag --output text)
      aws cloudfront-keyvaluestore put-key --kvs-arn "$KVS_ARN" --key "docs" --value "https://example.com/docs" --if-match "$ETAG"

      ETAG=$(aws cloudfront-keyvaluestore describe-key-value-store --kvs-arn "$KVS_ARN" --query ETag --output text)
      aws cloudfront-keyvaluestore put-key --kvs-arn "$KVS_ARN" --key "gh" --value "https://github.com" --if-match "$ETAG"
    EOT
  }
}

resource "aws_cloudfront_function" "redirect" {
  name    = "go-redirect"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = templatefile("${path.module}/redirect.js", {
    kvs_id = aws_cloudfront_key_value_store.redirects.id
  })

  key_value_store_associations = [aws_cloudfront_key_value_store.redirects.arn]
}

resource "aws_s3_bucket" "origin" {
  bucket_prefix = "go-redirect-origin-"
}

resource "aws_s3_bucket_public_access_block" "origin" {
  bucket = aws_s3_bucket.origin.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "redirects" {
  enabled = true
  comment = "go-redirect-with-kvs"

  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = "placeholder"
  }

  default_cache_behavior {
    target_origin_id       = "placeholder"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
