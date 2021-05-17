module "webserver_module" {
  source        = "github.com/nazy67/terraform//modules/webserver"
  env           = terraform.workspace
  instance_type = "t2.micro"

  remote_state = {
    bucket               = "terraform-nazy-state"
    key                  = "ws-homework/${terraform.workspace}/rds.tfstate" #full path to terraform-nazy-state/ws-homework/dev/rds.tfstate
    region               = "us-east-1"
    workspace_key_prefix = "ws-homework"
  }
}