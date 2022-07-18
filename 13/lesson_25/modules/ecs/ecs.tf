resource "aws_ecs_cluster" "this" {
    name = local.ecs_cluster_name

    capacity_providers = [aws_ecs_capacity_provider.this.name]
}

resource "aws_ecs_service" "this" {
    name = "${var.name}-ecs-service"

    cluster = aws_ecs_cluster.this.id
    task_definition = aws_ecs_task_definition.this.arn
    desired_count = 2

    network_configuration {
        subnets = data.aws_subnets.main.ids
        security_groups = var.security_group_ids
    }

    deployment_minimum_healthy_percent = 0

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = "app"
        container_port   = 80
    }
}

resource "aws_ecs_task_definition" "this" {
    family = "${var.name}-task-def"
    network_mode = "bridge"
    container_definitions = jsonencode([{
        name = "app"
        image = var.docker_image
        cpu = 1
        memory = 128
        essential = true
        portMappings = [{
            containerPort = 80
            hostPort = 80
        }]
    }])
}

resource "aws_ecs_capacity_provider" "this" {
    name = "${var.name}-capacity-provider"

    auto_scaling_group_provider {
        auto_scaling_group_arn = aws_autoscaling_group.this.arn
        managed_termination_protection = "ENABLED"

        managed_scaling {
            maximum_scaling_step_size = 1000
            minimum_scaling_step_size = 1
            status                    = "ENABLED"
            target_capacity           = 1
        }
    }
}
