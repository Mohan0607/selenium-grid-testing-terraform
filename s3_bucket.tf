# # create S3 Bucket:
# resource "aws_s3_bucket" "selenium" {
#   bucket_prefix = var.bucket_prefix #prefix appends with timestamp to make a unique identifier
#   tags = {
#     "Project"   = "hands-on.cloud"
#     "ManagedBy" = "Terraform"
#   }
#   force_destroy = true
# }
# # create bucket ACL :
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.selenium.id
#   acl    = "private"
# }
# # block public access :
# resource "aws_s3_bucket_public_access_block" "public_block" {
#   bucket = aws_s3_bucket.selenium.id
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
# }
# # encrypt bucket using SSE-S3:
# resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
#   bucket = aws_s3_bucket.selenium.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# # create S3 website hosting:
# resource "aws_s3_bucket_website_configuration" "website" {
#   bucket = aws_s3_bucket.selenium.id
#   index_document {
#     suffix = "index.html"
#   }
#   error_document {
#     key = "error.html"
#   }
# }
# # add bucket policy to let the CloudFront OAI get objects:
# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.selenium.id
#   policy = data.aws_iam_policy_document.bucket_policy_document.json
# }
# #upload website files to s3:
# resource "aws_s3_object" "object" {
#   bucket = aws_s3_bucket.selenium.id
#   for_each     = fileset("uploads/", "*")
#   key          = "website/${each.value}"
#   source       = "uploads/${each.value}"
#   etag         = filemd5("uploads/${each.value}")
#   content_type = "text/html"
#   depends_on = [
#     aws_s3_bucket.bucket
#   ]
# }

# # data source to generate bucket policy to let OAI get objects:
# data "aws_iam_policy_document" "bucket_policy_document" {
#   statement {
#     actions = ["s3:GetObject"]
#     resources = [
#       aws_s3_bucket.bucket.arn,
#       "${aws_s3_bucket.bucket.arn}/*"
#     ]
#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
#     }
#   }
# }