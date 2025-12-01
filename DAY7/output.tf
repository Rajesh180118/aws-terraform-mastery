# output "bucket_arn" {
#   description = "The ID of the S3 bucket"
#   value       = aws_s3_bucket.first_bucket.arn
# }

# output "name" {
#   value = aws_s3_bucket.first_bucket.bucket
# }
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    environment=aws_security_group.allow_tls.tags["Environment"]
    from_port=aws_vpc_security_group_ingress_rule.allow_tls_ipv4.from_port
    # security_group_id = aws_security_group.allow_tls.id
  }
  
}