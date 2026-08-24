resource "aws_ecs_cluster" "main" {
  name = "terraform-ecs-cluster-${var.github_username}"
}

resource "aws_iam_role" "ecs_node_role" {
  name = "ecs-node-role-${var.github_username}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_node_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name = "ecs-node-profile-${var.github_username}"
  role = aws_iam_role.ecs_node_role.name
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix            = "ecs-lt-${var.github_username}-"
  image_id               = data.aws_ami.ecs_optimized.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.ecs_tasks_security_group_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_node.arn
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config
              EOF
  )
}

resource "aws_autoscaling_group" "ecs" {
  name                = "ecs-asg-${var.github_username}"
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "main" {
  name = "cp-${var.github_username}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role-${var.github_username}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app-task-${var.github_username}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "nginxdemos/hello"
      cpu       = 100
      memory    = 128
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name                               = "app-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.ecs_tasks_security_group_id]
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_ecs_cluster_capacity_providers.main]
}