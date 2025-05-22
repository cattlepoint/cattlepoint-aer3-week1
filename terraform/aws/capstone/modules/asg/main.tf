resource "aws_launch_template" "asg_launch_template" {
  name_prefix            = "${var.project_id}-lt"
  image_id               = data.aws_ami.amazon_linux_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.allow_http

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd git
    systemctl enable httpd
    systemctl start httpd
    cd /var/www/html
    git init
    git pull https://github.com/drehnstrom/space-invaders.git
    touch health
  EOF
  )
}

data "aws_ami" "amazon_linux_ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_autoscaling_group" "main_asg" {
  name                = "${var.project_id}-asg"
  desired_capacity    = var.instance_count_desired
  min_size            = var.instance_count_min
  max_size            = var.instance_count_max
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }
  target_group_arns = [var.main_alb_tg_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_id}-asg-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_id}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project_id}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
