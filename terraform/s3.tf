
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  tags = {
    Name        = "StaticWebsiteBucket"
    Environment = "Dev"
  }

  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.bucket

  index_document {
    suffix = "web.html"
  }

  error_document {
    key = "web.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "web_file" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "web.html"
  source       = "../static_web/web.html"
  etag         = filemd5("../static_web/web.html")
  content_type = "text/html"
  #acl          = "public-read"
}

resource "aws_s3_object" "css_file" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "styles.css"
  source       = "../static_web/styles.css"
  etag         = filemd5("../static_web/styles.css")
  content_type = "text/css"
  #acl          = "public-read"
}
