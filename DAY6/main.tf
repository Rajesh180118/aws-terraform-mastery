

# Create a simple S3 bucket
resource "aws_s3_bucket" "first_bucket" {
  #   bucket = local.bucket_name_locals  // Using local variable
  bucket = var.bucket_name // Using variable directly or tfvars value 
  tags = {
    Name = "My bucket"
  }
}