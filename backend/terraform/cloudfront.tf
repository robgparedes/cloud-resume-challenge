resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"

  aliases = [
    "robertgparedes.com"
  ]

  web_acl_id = "arn:aws:wafv2:us-east-1:490058394460:global/webacl/CreatedByCloudFront-c46878ee/39cb9665-ea6a-4834-b503-be8e4851cce7"

  origin {
    domain_name = "rob-myresume-cloud-challenge.s3-website-ap-southeast-2.amazonaws.com"
    origin_id   = "rob-myresume-cloud-challenge.s3.ap-southeast-2.amazonaws.com-mm3fysf3py4"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "rob-myresume-cloud-challenge.s3.ap-southeast-2.amazonaws.com-mm3fysf3py4"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:490058394460:certificate/3cee356e-20e4-4844-8cd6-1caf6fd63914"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "myresume-cloud-challenge"
  }
}