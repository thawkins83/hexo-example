terraform {
  backend "s3" {
  }
}

locals {
  purpose = {
    "Purpose" = var.purpose
  }
  bucket_name = "${var.bucket_name}.${var.domain}"
}

resource "aws_s3_bucket" "blog_bucket" {
  bucket = "${local.bucket_name}"
  region = "${var.region}"

  versioning {
    enabled = true
  }

}

resource "aws_s3_bucket_policy" "blog_bucket_bucket_policy" {
  depends_on = ["aws_s3_bucket.blog_bucket", "aws_s3_bucket_public_access_block.blog_bucket_access"]
  bucket = "${aws_s3_bucket.blog_bucket.bucket}"
  policy = "${data.aws_iam_policy_document.blog_bucket_policy_document.json}"
}

resource "aws_s3_bucket_public_access_block" "blog_bucket_access" {
  depends_on = ["aws_s3_bucket.blog_bucket"]
  bucket = "${aws_s3_bucket.blog_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "circleci_user" {
  name = "${var.circleci_user}"
}

resource "aws_iam_user_policy" "circlec_user_inline_policy" {
  name = "${var.circleci_user}_policy"
  user = "${aws_iam_user.circleci_user.name}"

  policy = "${data.aws_iam_policy_document.circleci_user_generated_policy.json}"
}

resource "aws_route53_record" "blog" {
  depends_on = ["aws_s3_bucket_public_access_block.blog_bucket_access", "aws_s3_bucket.blog_bucket"]
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${local.bucket_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}