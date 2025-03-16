resource "random_string" "random" {
	length = 6
	special = false
	upper = false
}

resource "aws_s3_bucket" "bucket"{
	bucket = "${var.bucket_name}-${random_string.random.result}"
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket, aws_s3_bucket_public_access_block.bucket]

  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}
