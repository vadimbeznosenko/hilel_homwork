data "aws_ami" "ecs_optimized" {
    owners = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    most_recent = true
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_ec2_instance_type_offerings" "supported_azs" {
  filter {
    name = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone-id"
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name = "availability-zone-id"
    values = data.aws_ec2_instance_type_offerings.supported_azs.locations
  }
}