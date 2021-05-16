terraform {
  backend "s3" {
  bucket = "terraform-nazy-state"
  key = "ws.tfstate"
  region = "us-east-1"
  dynamodb_table = "terraform-state-locks"
  workspace_key_prefix = "workspace-prefix"
  } 
}