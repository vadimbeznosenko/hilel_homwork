resource "aws_launch_template" "this" {
    name = "${var.name}-lt"

    image_id = data.aws_ami.ecs_optimized.id
    instance_type = var.instance_type
    iam_instance_profile {
        name = aws_iam_instance_profile.this.name
    }

    key_name = var.key_name

    instance_market_options {
        market_type = "spot"
    }

    vpc_security_group_ids = var.security_group_ids

    user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
        ecs_cluster_name = local.ecs_cluster_name
    }))

    tags = {
        Name = "${var.name}-lt"
    }
}

resource "aws_autoscaling_group" "this" {
    name = "${var.name}-asg"

    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity

    vpc_zone_identifier = data.aws_subnets.main.ids
    launch_template {
        id = aws_launch_template.this.id
        version = "$Latest"
    }

    protect_from_scale_in = true

    tag {
        key = "Name"
        value = "${var.name}-asg"
        propagate_at_launch = true
    }

    lifecycle {
        ignore_changes = [desired_capacity]
    }
}
