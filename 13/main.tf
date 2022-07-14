# Call modules
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "Hillel"
      Lesson    = "24"
      Terraform = "True"
    }
  }
}

locals {
  alb_name      = "example-alb"
  instance_name = "example-ec2"
  sg = "example-sg"
}

module "example_alb" {
  source = "./modules/alb"

  name            = local.alb_name
  security_groups = [module.sg.alb.id]

  vpc_id       = data.aws_vpc.main.id
  subnets      = data.aws_subnets.main.ids
  instance_ids = [module.example_instance.id]
}



module "sg" {
  source = "./modules/sg"
  name = "sg"

}


module "example_instance" {
  source = "./modules/instance"

  name            = local.instance_name
  security_groups = [module.sg.alb_sg_ingress_443.id]

  key_name = "hillel-test"
}



output "web_page_address" {
  value     = module.example_alb.dns_name
  sensitive = false
}