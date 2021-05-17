module "rds_module" {
  source         = "github.com/nazy67/terraform//modules/rds"
  env            = terraform.workspace
  storage        = 10
  skip_snapshot  = "true"
  instance_class = "db.t2.micro"
  username       = "${terraform.workspace}_ws_user"
}