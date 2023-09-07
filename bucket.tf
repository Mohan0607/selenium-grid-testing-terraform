locals {
  bucket_name = join("-", [var.resource_name_prefix, var.bucket_name])
}


# create S3 Bucket:
resource "aws_s3_bucket" "selenium" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "selenium" {
  bucket = aws_s3_bucket.selenium.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# create bucket ACL :

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.selenium.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.selenium]
}

# block public access :
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.selenium.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
# encrypt bucket using SSE-S3:
resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.selenium.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# create S3 website hosting:
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.selenium.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}


resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.selenium.id
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PolicyForCloudFrontPrivateContent",
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutBucketAcl"],
        Resource = [
          "${aws_s3_bucket.selenium.arn}",
          "${aws_s3_bucket.selenium.arn}/*"
        ],
        Principal = {
          AWS = "${aws_cloudfront_origin_access_identity.selenium_ui.iam_arn}"
        }
      }
    ]
  })
  depends_on = [
    aws_s3_bucket_public_access_block.public_block
  ]
}
