provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "Hillel"
      Lesson    = "25"
      Terraform = "True"
    }
  }
}

locals {
    registry_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    alb_name = "example-alb"
}

resource "aws_ecr_repository" "example_app" {
    name = var.ecr_repo_name
    image_scanning_configuration {
        scan_on_push = true
    }

    provisioner "local-exec" {
        command =<<EOF
git clone ${var.git_repo_url} /tmp/example && cd /tmp/example && docker build  --platform linux/amd64 -t ${local.registry_url}/${var.ecr_repo_name} . && cd $OLDPWD
aws ecr get-login-password | docker login --username AWS --password-stdin ${local.registry_url}
docker push ${local.registry_url}/${var.ecr_repo_name}
rm -rf /tmp/example
        EOF
    }
}

module "example-ecs" {
    source = "./modules/ecs"

    name = "example"
    key_name = "hillel-test"
    instance_type = "t3a.medium"
    docker_image = "${local.registry_url}/${var.ecr_repo_name}"
    security_group_ids = [aws_security_group.instance_sg.id]

    target_group_arn = module.example_alb.tg_arn
}


resource "aws_security_group" "instance_sg" {
  name        = "ecs-instance-sg"
  description = "SG for our example instance"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "instance_sg_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow ssh traffic for debugging"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_sg_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow HTTP traffic for debugging"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_sg_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "alb_sg" {
  name        = "${local.alb_name}-sg"
  description = "SG for our example ALB"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "alb_sg_ingress_80" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow traffic on port 80 for ALB SG"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_egress_instance" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow traffic on instances port 80 from ALB SG"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.instance_sg.id
}

module "example_alb" {
  source = "../modules/alb"

  name            = local.alb_name
  security_groups = [aws_security_group.alb_sg.id]

  vpc_id       = data.aws_vpc.main.id
  subnets      = data.aws_subnets.main.ids
  instance_ids = []
  tg_target_type = "ip"

}

resource "aws_route53_record" "alb" {
    zone_id = data.aws_route53_zone.main.zone_id
    name    = "example-app.${data.aws_route53_zone.main.name}"
    type    = "CNAME"
    ttl     = "300"
    records = [module.example_alb.dns_name]
     depends_on = [example_alb]
}


/* resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "example-app.${data.aws_route53_zone.main.name}"
  type = "A"

  alias {
    name = aws_elb.service.dns_name 
    zone_id = data.aws_route53_zone.main.zone_id
    evaluate_target_health = false
  }
} */