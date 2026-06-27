# IAM Role that can be assumed by EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-ec2-iam-role"
  }
}

# Basic Custom IAM Policy (e.g. allowing metadata reads or generic bucket listing as an example)
resource "aws_iam_policy" "basic_policy" {
  name        = "${var.environment}-basic-ec2-policy"
  description = "A basic IAM policy for EC2 instance demo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the custom basic policy to the IAM Role
resource "aws_iam_role_policy_attachment" "basic_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.basic_policy.arn
}

# Attach AmazonSSMManagedInstanceCore standard policy (recommended best-practice for secure console access)
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create IAM Instance Profile (bridges the role to the EC2 resource)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
