resource "aws_ecr_repository" "worker" {
  name                 = "worker"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "result" {
  name                 = "result"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "vote" {
  name                 = "vote"

  image_scanning_configuration {
    scan_on_push = true
  }
}


# IAM role for ECR access
resource "aws_iam_role" "ecr_access_role" {
  name = "ecr-access-role"

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

# IAM instance profile
resource "aws_iam_instance_profile" "ecr_access_profile" {
  name = "ecr-access-instance-profile"
  role = aws_iam_role.ecr_access_role.name
}

# IAM policy for ECR access
resource "aws_iam_role_policy" "ecr_pull_policy" {
  name = "ecr-pull-policy"
  role = aws_iam_role.ecr_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ],
        Resource = "*"
      },
    ]
  })
}


output "ecr_profile" {
  value = aws_iam_instance_profile.ecr_access_profile.name
}

