terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "3.71.0"
		}
	}	
}

provider "aws" {
	region = "eu-west-2"
}

resource "aws_kms_key" "key1" {
	deletion_window_in_days = 7
	enable_key_rotation = true
}

resource "aws_kms_key" "key2" {
        deletion_window_in_days = 7
	enable_key_rotation = true
}

resource "aws_s3_bucket" "bucket" {
	acl = "private"
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				kms_master_key_id = aws_kms_key.key1.arn
				sse_algorithm = "aws:kms"
			}
		}
	}
	
	logging {
		target_bucket = aws_s3_bucket.logging.id
	}
	
	versioning {
		enabled = var.versioning == "enabled" ? true : false
	}
}

resource "aws_s3_bucket_policy" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	policy = <<POLICY1
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"EnforceTls",
      "Action":"s3:*",
      "Effect":"Deny",
      "Principal":"*",
      "Resource":[
        "${aws_s3_bucket.bucket.arn}/*",
        "${aws_s3_bucket.bucket.arn}"
      ],
      "Condition":{
        "Bool":{
          "aws:SecureTransport": "false"
        },
        "NumericLessThan":{
          "s3:TlsVersion": "1.2"
        }
      }
    }
  ]
}
POLICY1
}

resource "aws_s3_bucket" "logging" {
	acl = "private"
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				kms_master_key_id = aws_kms_key.key2.arn
				sse_algorithm = "aws:kms"
			}
		}
	}
	
	versioning {
		enabled = true
	}
}

resource "aws_s3_bucket_policy" "logging" {
	bucket = aws_s3_bucket.logging.id
	
	policy = <<POLICY2
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"EnforceTls",
      "Action":"s3:*",
      "Effect":"Deny",
      "Principal":"*",
      "Resource":[
        "${aws_s3_bucket.logging.arn}/*",
        "${aws_s3_bucket.logging.arn}"
      ],
      "Condition":{
        "Bool":{
          "aws:SecureTransport": "false"
        },
        "NumericLessThan":{
          "s3:TlsVersion": "1.2"
        }
      }
    }
  ]
}
POLICY2
}
