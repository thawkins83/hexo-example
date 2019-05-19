data "aws_iam_policy_document" "blog_bucket_policy_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type = "*"
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
}

data "aws_route53_zone" "domain" {
  name = "${var.domain}."
}