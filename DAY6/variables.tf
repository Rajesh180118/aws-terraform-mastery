variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "mys3bucketbyraja1801testingvariable"

}
variable "random_suffix" {
  description = "Random suffix to ensure unique bucket name"
  type        = string
  default     = "001"
}