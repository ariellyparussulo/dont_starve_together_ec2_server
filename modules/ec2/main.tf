data "aws_region" "current" {}

data "template_file" "init" {
  template = file("./_resources/init.sh.tpl")

  vars = {
    cluster_name = var.cluster_name
    cluster_description = var.cluster_description
    cluster_intention = var.cluster_intention
    cluster_password = var.cluster_password
    cluster_token_parameter = var.cluster_token_parameter
    max_players = var.max_players
    region = data.aws_region.current.name
  }
}

data "template_cloudinit_config" "init" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.init.rendered
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "dst_instance_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "dst_instance_role"
  path = "/"

  inline_policy {
    name = "dst_allow_read_parameters"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ssm:GetParameter"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
        }
    ]
  })
}

resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  user_data_base64            = data.template_cloudinit_config.init.rendered
  security_groups             = [var.security_group]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
}