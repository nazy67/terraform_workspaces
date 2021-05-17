terraform {
  backend "s3" {
    bucket               = "terraform-nazy-state"
    key                  = "webserver.tfstate"
    region               = "us-east-1"
    dynamodb_table       = "terraform-state-locks"
    workspace_key_prefix = "ws-homework"
  }
}