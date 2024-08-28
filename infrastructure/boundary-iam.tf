resource "aws_iam_role" "boundary_controller" {
  name = "${var.project_name}-boundary-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "boundary_controller" {
  name = "${var.project_name}-boundary-controller-profile"
  role = aws_iam_role.boundary_controller.name
}