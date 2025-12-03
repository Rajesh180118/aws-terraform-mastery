

# Create a simple S3 bucket
resource "aws_s3_bucket" "first_bucket" {
  #   bucket = local.bucket_name_locals  // Using local variable
  count= length(var.bucket_name) #meta-argument to create multiple resources

#  count=2 #meta-argument to create multiple resources
  bucket = var.bucket_name[count.index] // Using variable directly or tfvars value 
  tags = var.tags
}

resource "aws_s3_bucket" "second_bucket" {
  
  for_each = var.bucket_name_set #meta-argument to create multiple resources
  bucket = each.value // Using variable directly or tfvars value 
  tags = var.tags

  depends_on = [ aws_s3_bucket.first_bucket ]
  
}
