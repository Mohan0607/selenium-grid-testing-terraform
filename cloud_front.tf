# locals {
#   selenium_ui_cloudfront_comment = title(join(" ", [var.resource_name_prefix, "Selenium Portal"]))
# }

# resource "aws_cloudfront_origin_access_identity" "selenium_ui" {
#   comment = local.selenium_ui_cloudfront_comment
# }

# resource "aws_cloudfront_distribution" "selenium_ui" {
#   comment = local.selenium_ui_cloudfront_comment

#   origin {
#     domain_name = aws_s3_bucket.selenium.bucket_regional_domain_name
#     origin_id   = aws_s3_bucket.selenium.id

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.selenium_ui.cloudfront_access_identity_path
#     }
#   }

#   custom_error_response {
#     error_caching_min_ttl = 10
#     error_code            = 403
#     response_code         = 200
#     response_page_path    = "/index.html"
#   }

#   custom_error_response {
#     error_caching_min_ttl = 10
#     error_code            = 404
#     response_code         = 200
#     response_page_path    = "/index.html"
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"


#   depends_on = [
#     aws_s3_bucket.selenium
#   ]

#   #aliases = var.selenium_cf_aliases

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = aws_s3_bucket.selenium.id
#     compress         = true

#     # This is set to CacheOptimized policy
#     cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 0
#     max_ttl                = 0
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE", "IN", "IR"]
#     }
#   }


#   viewer_certificate {
#     minimum_protocol_version = "TLSv1"
#     #acm_certificate_arn            = var.cloufront_acm_cert_arn
#     ssl_support_method             = "sni-only"
#     cloudfront_default_certificate = true
#   }
# }

