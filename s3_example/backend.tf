terraform {
  backend "s3" {
  bucket = "terraform-nazy-state"
  key = "s3.tfstate"
  region = "us-east-1"
  dynamodb_table = "terraform-state-locks"
  workspace_key_prefix = "workspace-prefix"
  
  } 
}