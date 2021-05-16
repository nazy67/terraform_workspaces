module "s3" {
  source =  "github.com/nazy67/terraform/s3_module_09//modules/s3" 

  s3_bucket_name = "${terraform.workspace}-workspace-example-bucket"
  versioning_enabled = var.is_versioning_enabled
  principals = var.principals_list
  env = terraform.workspace
}