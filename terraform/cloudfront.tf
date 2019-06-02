locals {
  s3_origin_id = "S3-${local.bucket_name}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = ["aws_lambda_function.redirect_lambda"]
  origin {
    domain_name = "${aws_s3_bucket.blog_bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.blog_origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["${local.bucket_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.redirect_lambda.arn}:${aws_lambda_function.redirect_lambda.version}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
    acm_certificate_arn            = "${data.aws_acm_certificate.naked_cert.arn}"
  }

  tags = "${merge(local.purpose)}"
}

resource "aws_cloudfront_origin_access_identity" "blog_origin_access_identity" {
  comment = "access-${local.bucket_name}.s3.amazonaws.com"
}

resource "aws_lambda_function" "redirect_lambda" {
  filename         = "${path.module}/files/lambda.zip"
  function_name    = "blog-redirect2"
  role             = "${aws_iam_role.redirect_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs8.10"
  publish          = true

  tags = "${merge(local.purpose)}"
}

resource "aws_iam_role" "redirect_role" {
  name               = "lambda-edge-blog2"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_redirect_trust_policy.json}"

  tags = "${merge(local.purpose)}"
}

resource "aws_iam_policy" "lambda_redirect_policy" {
  name   = "LambdaRedirectPolicy2"
  path   = "/service-role/"
  policy = "${data.aws_iam_policy_document.lambda_redirect_policy.json}"
}

resource "aws_iam_role_policy_attachment" "redirect_role_policy_attachment" {
  role       = "${aws_iam_role.redirect_role.name}"
  policy_arn = "${aws_iam_policy.lambda_redirect_policy.arn}"
}

