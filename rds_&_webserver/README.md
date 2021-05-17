# Terraform Workspaces RDS and Webserver

Terraform workspace with 2 tier application example contains:

- RSD workspace
- Webserver workspace

In this example I have `terraform-nazy-state` s3 bucket, which is already created on AWS, and I will use that bucket to store rds.tfstate and webserver.tfstate files. For enviroment isolation for state files I'm using terraform workspace, where I created different workspaces let's say `dev` or `qa` and deployed my resources from there. 
From the root module I'm calling child rds and webserver modules, where the source for rds and webserver are coming from github repository:

```
source = "github.com/nazy67/terraform/aws_terraform_modules//modules/web_server"
```

or if it's locally just give a relative path to it, as it shown next,

```
source = "../../../aws_terraform_modules/modules/web_server"
```

both will work. Webserver child module has a remote_state.tf file where I give the description of rds.tfstate file, which I want to use to retrive a data from rds state file such as address (endpoint) and username of database user. I used the data source for rds.tfstate file in webserver child module, but in webserver root module  I faced an issue, terraform couldn't find rds.tfstate in a refered s3 bucket. To solve that, I have to give a full path to that rds.tfstate file (it is shown below), when I worked with folder structure for environment isolation I just had to pass the name of tf.state file. Terraform workspace in this case behaves different and giving a full path to rds.tfstate file is the fixed the issue.

You can either do it from the state file, but just key values, because this resources will be created and the names will be known after the creation in the next line of code can show it better:

```
data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket =   var.remote_state["bucket"]
    key = "${var.remote_state["workspace_key_prefix"]}/${var.env}/${var.remote_state["key"]}". # here we are just passing key values
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
 Or we can change it on root webserver module:

 ```
  remote_state = {
     bucket = "terraform-nazy-state"
     key = "ws-homework/${terraform.workspace}/rds.tfstate"
     region = "us-east-1"
     workspace_key_prefix = "ws-homework"
  } 
}
 ```

 and child webserver module data remote_state file will look in the next code:

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