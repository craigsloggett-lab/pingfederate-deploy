resource "aws_s3_bucket" "artifacts" {
  bucket           = "${var.project_name}-pingfederate-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace = "account-regional"
  force_destroy    = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "pingfederate_zip" {
  bucket      = aws_s3_bucket.artifacts.id
  key         = basename(var.pingfederate_zip_path)
  source      = var.pingfederate_zip_path
  source_hash = filemd5(var.pingfederate_zip_path)

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-zip" })
}

resource "aws_s3_object" "pingfederate_license" {
  bucket      = aws_s3_bucket.artifacts.id
  key         = basename(var.pingfederate_license_path)
  source      = var.pingfederate_license_path
  source_hash = filemd5(var.pingfederate_license_path)

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-license" })
}
