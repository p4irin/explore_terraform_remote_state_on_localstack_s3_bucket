resource "local_file" "local-file" {
    filename = "local-file"
    content = "This Terraform configuration uses an s3 bucket to store remote state on LocalStack"
}