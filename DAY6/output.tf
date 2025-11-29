output "bucket_arn" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.first_bucket.arn
}

output "name" {
  value = aws_s3_bucket.first_bucket.bucket
}