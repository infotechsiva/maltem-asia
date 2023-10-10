## Creating an S3 bucket for the front-end.
resource "aws_s3_bucket" "front_end_bucket" {
  bucket = var.frontend_bucket_name
  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "frontend" })
}


### Creating a CloudFront distribution for the front-end
resource "aws_cloudfront_distribution" "front_end_distribution" {
  origin {
    domain_name = aws_s3_bucket.front_end_bucket.bucket_domain_name
    origin_id   = "S3BucketOrigin"
  }

  enabled             = true
  default_root_object = "index.html"

  # Viewer certificate settings
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
  geo_restriction {
    restriction_type = "whitelist"
    locations        = ["SG"]  # Add the desired countries or regions
  }
  }

  # Cache behavior settings
  default_cache_behavior {
    target_origin_id = "S3BucketOrigin"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    
    # Forward all query strings to S3
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
        
      }
    }

    # Cache settings
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ##Logging settings uncomment below if required
  logging_config {
    bucket         = "siva-log-bucket.s3.amazonaws.com"
    include_cookies = false
    prefix         = "cloudfront-logs/"
  }

  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "frontend" })

}
