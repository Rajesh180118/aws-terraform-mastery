resource "aws_s3_bucket" "cloud_front_s3_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.cloud_front_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.cloud_front_s3_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.example]

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "${aws_s3_bucket.cloud_front_s3_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn": "${aws_cloudfront_distribution.s3_distribution.arn}"
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac"
  description                       = "cloudfront to s3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.cloud_front_s3_bucket.bucket
  for_each = fileset(
    "${path.module}/www",
    "**/*"
  )
  key    = each.value
  source = "${path.module}/www/${each.value}"
  etag   = filemd5("${path.module}/www/${each.value}")
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "json" = "application/json",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "ico"  = "image/x-icon",
    "txt"  = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

locals {
  s3_origin_id = "S3cloudfrontOrigin"
}

#To create cloud front distribution only with default certificate
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name              = aws_s3_bucket.cloud_front_s3_bucket.bucket_regional_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id  
#     origin_id                = local.s3_origin_id
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

# #   aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }


#   price_class = "PriceClass_100"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
    
#     }
#   }


#   viewer_certificate {
#     # acm_certificate_arn = data.aws_acm_certificate.my_domain.arn
#     # ssl_support_method  = "sni-only"
#     cloudfront_default_certificate = true
#   }
# }

# output "named_domain" {
#   value = aws_cloudfront_distribution.s3_distribution.domain_name
  
# }




#To create cloud front distribution with custom domain and certificate from ACM
locals {
  my_domain = "buildwithrajesh.qzz.io"  # Replace with your actual domain
}

data "aws_acm_certificate" "my_domain" {
  region   = "us-east-1"
  domain   = "${local.my_domain}"
  statuses = ["ISSUED"]
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.cloud_front_s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id  
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

#   aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]
aliases = ["${local.my_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    
    }
  }


  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.my_domain.arn
    ssl_support_method  = "sni-only"
    # cloudfront_default_certificate = true
  }
}

output "named_domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
  
}
data "aws_route53_zone" "my_domain" {
  name = local.my_domain
}
resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = local.my_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}