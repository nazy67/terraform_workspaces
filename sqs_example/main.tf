resource "aws_sqs_queue" "terraform-queue" {
    name = "${terraform.workspace}-terraform-nazy-queue"
}
resource "random_pet" "test" {
  count = terraform.workspace == "qa" ? 1 : 0
}