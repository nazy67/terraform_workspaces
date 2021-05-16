# Terraform workspaces

Workspaces that we used before was a default workspace, but we can create our own custom workspace using terraform workspace commands:

- `terraform workspace new` - will create a new workspace
- `terraform workspace list` - will list existing workspaces
- `terraform workspace show` - will show the current workspace
- `terraform workspace select` - will select the workspace
- `terraform workspace delete` - will delete the workspace

We have a multiple examples of terraform workspace usage in this repository:

- s3_bucket_example, 
- sqs_example, 
- rds_example, 
- webserver_example

and all of them contain two enviromental variables `dev` and `qa` for each of them we create terraform workspaces called `dev` and `qa`. To provision in terraform workspace dev we run a command `terraform plan/apply -var-file=tfvars.dev.tf` for qa we run pass qa.tf variables file.

Previously, when we worked with environment isolation using folder structure our state file was inside of every resource folder, for example for rds in dev env one backend.tf and for qa env is separate backend.tf where state file names were different depending which environment our state files are created for, and the name issue for our resouces we solve by adding interpolations to resources name,

```
resource "aws_sqs_queue" "terraform-queue" {
    name = "${var.env}-terraform-nazy-queue"
```

and we pass variables file `dev.tf` or `qa.tf`. Let's say that we have a resource in dev env, and we use same name for a state file and apply for qa env terraform's behavior will be go and destroy existing resource and create the new one with qa env name. But when we work on terraform workspace we can create the same resource for different environments and the name of our state file in backend.tf will not give us any errors, because it's is getting created in different workspaces also terraform workspace has an option to prefix our state files with `env:/`. But since we don’t want our resources with the same names, otherwise it will get confusing really fast. For the backend setting we will use,

```
workspace_key_prefix = "workspace-prefix"
```
So what it does is instead of `env:/`  we will have  `"workspace-prefix"`. In AWS Console our state files will look like in the next image for dev workspace:

<img src="aws.img/workspace_dev.png" alt="aws" width="700" height="100">

and for qa workspace:

<img src="aws.img/wokspace_qa.png" alt="aws" width="700" height="100">

Whenever you do any changes in backend.tf always re apply `terraform init`. Working on terraform gives us opportunity to use the same code for two different environments and where we have two different state files inside of one s3 bucket. So we can apply, destroy our resources independently from each other. In forder structure we mention that we can create additional custom resources inside of our root module, we also used count module to specifically saying for dev env create additional resource and for qa env don't create it.  
    
```
resource "aws_sqs_queue" "terraform-queue" {
    name = "${var.env}-terraform-nazy-queue"
}
resource "random_pet" "test" {
  count = var.env == "qa" ? 1 : 0
}
```

We can do the same thing on terraform workspaces, and one more thing that I mentioned earlier we solve the name issue for our resource name with interpolations, but we can also use workspace name for it, in that case we don't depend on our tfvars/dev.tf or tfvars/qa.tf files.

```
resource "aws_sqs_queue" "terraform-queue" {
    name = "${terraform.workspace}-terraform-nazy-queue"
}
resource "random_pet" "test" {
  count = terraform.workspace == "qa" ? 1 : 0
}
```

We can use terraform workspace in modules as well and the second example with s3 bucket. Here we do some changes by adding interpolations into the name of our s3 bucket, which terraform will get from the workspace name where we are creation our resources. If you have multiple terraform deployments for multiple applications you can set the same tfstate file and set the same prefix, and the workspace you can use the same for multiple environments just use the different file name for each resource. Just as we did on the example below,

```
module "s3" {
  source =  "github.com/nazy67/terraform/s3_module_09//modules/s3" 

  s3_bucket_name = "${terraform.workspace}-workspace-example-bucket"
  versioning_enabled = var.is_versioning_enabled
  principals = var.principals_list
  env = terraform.workspace
}
```
The source module we are getting from our git repository, here we have to give // forward slashes to specify which child module we want to call from our root module.
In tfvars/dev.tf and qa.tf files you need to give your accound_id, for principal list.

With terraform workspaces we can use the same resources for different environment and keep isolated our backend (tfstate file) file.

A common use for workspaces you use the parallel copy of your infrastructure  for testing without touching your main production infrastructure, after that you can apply those changes your main infrastructure.

## Links

[Terraform workspaces](https://www.terraform.io/docs/language/state/workspaces.html)

## Notes

- Before you do any thing while you worknig on workspaces always check which environment you are working on by running command ```terraform workspace list``` or show, just to make sure where you are deploying your resources.

- You can not delete your workspace while you are inside of it.W

- If you leave workspace_prefix in your backend file, and you are not working with workspaces, it won't do anything when you provision your resources.
