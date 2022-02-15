resource "aws_s3_bucket" "storage_archive" {
  bucket = "${var.environment}-archive-service"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "archive_bucket_public_access" {
  bucket                  = aws_s3_bucket.storage_archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.storage_archive.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.user.arn}"
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.storage_archive.arn}",
        "${aws_s3_bucket.storage_archive.arn}/*"
      ]
    }
  ]
}
EOF
}


///////////////////////////////////////////// ARCHIVE USER
resource "aws_iam_user" "user" {
  name = "${var.environment}-archive-service-s3"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "sagemaker-policy-attachment"
  users      = [aws_iam_user.user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
