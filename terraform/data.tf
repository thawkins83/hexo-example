data "aws_iam_policy_document" "blog_bucket_policy_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["${aws_cloudfront_origin_access_identity.blog_origin_access_identity.iam_arn}"]
      type        = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.blog_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "circleci_user_generated_policy" {
  statement {
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.blog_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.blog_bucket.arn}"
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_redirect_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_redirect_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

data "aws_route53_zone" "domain" {
  name = "${var.domain}."
}

data "aws_acm_certificate" "naked_cert" {
  domain      = "${var.domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/files/lambda.zip"
}