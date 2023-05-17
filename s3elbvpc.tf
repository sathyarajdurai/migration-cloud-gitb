resource "aws_s3_bucket" "elb_logs" {
    bucket = "migration-elb-logs-cr"

    tags = {
        Name = "elb logs migration"
        Environment = "Lab"
    }
    
    lifecycle {
        prevent_destroy = false
        # prefix = "elblogs/AWSLogs/744618523292"
    }
}

resource "aws_s3_bucket_versioning" "elb_version" {
    bucket = aws_s3_bucket.elb_logs.id

    versioning_configuration {
      status = "Enabled"
    }
  
}

data "aws_iam_policy_document" "allow_lb" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::migration-elb-logs-cr/elblogs/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "allow-lb" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = data.aws_iam_policy_document.allow_lb.json
}


resource "aws_s3_bucket_server_side_encryption_configuration" "elb_encryption" {
  bucket = aws_s3_bucket.elb_logs.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

resource "aws_s3_bucket" "vpc_logs" {
    bucket = "migration-vpc-logs-cr"

    tags = {
        Name = "vpc logs migration"
        Environment = "Lab"
    }
    
    lifecycle {
        prevent_destroy = false
        # prefix = "elblogs/AWSLogs/744618523292"
    }
}

resource "aws_s3_bucket_versioning" "vpc_version" {
    bucket = aws_s3_bucket.vpc_logs.id

    versioning_configuration {
      status = "Enabled"
    }
  
}

data "aws_iam_policy_document" "allow_vpc" {
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::migration-vpc-logs-cr",
      "arn:aws:s3:::migration-vpc-logs-cr/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
            "bucket-owner-full-control"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
            "744618523292"
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
            "arn:aws:logs:*:744618523292:*"
      ]
    }
  }
  statement {
    sid = "AWSLogDeliveryCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::migration-vpc-logs-cr",
      "arn:aws:s3:::migration-vpc-logs-cr/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
            "744618523292"
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
            "arn:aws:logs:*:744618523292:*"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "allow-vpc" {
  bucket = aws_s3_bucket.vpc_logs.id
  policy = data.aws_iam_policy_document.allow_vpc.json
}


resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_encryption" {
  bucket = aws_s3_bucket.vpc_logs.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }