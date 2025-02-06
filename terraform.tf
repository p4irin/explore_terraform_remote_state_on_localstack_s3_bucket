terraform {
  backend "s3" {
    key = "terraform.tfstate"
    bucket = "remote-state"
    region = "us-east-1"
    access_key = "test"
    secret_key = "test"
    force_path_style = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id  = true
    skip_region_validation = true
    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}
