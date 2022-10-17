# bucket definition
resource "aws_s3_bucket" "data_internal" {
  bucket_prefix = "data-internal-private-"
  //acl = "public-read"
}

resource "aws_s3_bucket_object" "public-folder" {
  bucket = aws_s3_bucket.data_internal.id
  key    = "public-stuff/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "logo_upload" {
  bucket =aws_s3_bucket.data_internal.id
  key           = "public-stuff/logo.png"
  source        = "private-data/public-stuff/logo.png"
  acl           = "public-read"
  content_type  = "image/png"
}

resource "aws_s3_bucket_object" "private_data_up" {
  for_each = fileset("private-data/", "*.txt")
  bucket   = aws_s3_bucket.data_internal.id
  key      = each.value
  source   = "private-data/${each.value}"
  etag     = filemd5("private-data/${each.value}")
}
