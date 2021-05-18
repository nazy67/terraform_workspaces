# Terraform Workspaces. With RDS and Webserver example.

## Description
Terraform workspaces contains two directories:
- RSD
- Webserver
Where each of them are calling a child module from github repository:
```
module "webserver_module" {
  source        = "github.com/nazy67/terraform//modules/webserver"
  env           = terraform.workspace
  instance_type = "t2.micro"
  ......
```
To store rds.tfstate and webserver.tfstate backend files we are using `terraform-nazy-state` s3 bucket, which is already created. For enviroment isolation `terraform workspaces` comed handy, here we created two workspaces `dev` and `qa` and deployed our resources from different workspaces.

Webserver child module has a remote_state.tf file where have data source of rds backend file (child module) we did it because we wanted to retrive some data from rds.tfstate file, such as address (endpoint) and the username of database user. But when we called that child module from a root module we faced an issue where terraform couldn't find rds.tfstate in a refered s3 bucket. To solve that, we have to give a full path to that rds.tfstate file (it is shown below), when we worked with folder structure for environment isolation we just had to pass the name of tfstate file. But since terraform behaves differently in terraform workspaces we used variable `remote_state` and passed the values to it in root module. Theres two ways of giving a full path to remote state file inside of remote_state.tf like this,
child webserver module:

 ```
 data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket =   var.remote_state["bucket"]
    key    = var.remote_state["key"]
    region = var.remote_state["region"]
 }                                                                      
}
```

root webserver module:

 ```
  remote_state = {
     bucket = "terraform-nazy-state"
     key = "ws-homework/${terraform.workspace}/rds.tfstate"
     region = "us-east-1"
     workspace_key_prefix = "ws-homework"
  } 
}
 ```

Or since the names of the resources will be known after the creation of resources we can do it this way too,

```
data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket =   var.remote_state["bucket"]
    key = "${var.remote_state["workspace_key_prefix"]}/${var.env}/${var.remote_state["key"]}". 
    region = var.remote_state["region"]
 }                                                                      
}
```

in this case root webserver module will look like this:

 ```
  remote_state = {
     bucket = "terraform-nazy-state"
     key    = "rds.tfstate"
     region = "us-east-1"
     workspace_key_prefix = "ws-homework"
  } 
}
```

## Notes 

- Before you do anything make sure to check which workspace you are working on, by running command terraform workspace show.

- The rds backend has to be created first, since we want to read from it remote state file.