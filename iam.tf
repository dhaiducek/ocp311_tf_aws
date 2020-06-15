# Create Master IAM role
resource "aws_iam_role" "ocp311_master_role" {
  name = "${local.cluster_id}_master_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
  
  tags =merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-master-role"
    )
  )
}

# Create Worker IAM role
resource "aws_iam_role" "ocp311_worker_role" {
  name = "${local.cluster_id}_worker_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF

  tags =merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-worker-role"
    )
  )
}

# Create Master IAM policy
resource "aws_iam_policy" "ocp311_master_policy" {
  name = "${local.cluster_id}_master_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "iam:PassRole",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Create Worker IAM policy
resource "aws_iam_policy" "ocp311_worker_policy" {
  name = "${local.cluster_id}_worker_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": "ec2:Describe*",
          "Resource": "*"
      }
  ]
}
EOF
}

# Attach Master IAM policy to the role
resource "aws_iam_policy_attachment" "ocp311_attach_master_policy" {
  name = "${local.cluster_id}_attach_master_policy"
  roles = [ aws_iam_role.ocp311_master_role.name ]
  policy_arn = aws_iam_policy.ocp311_master_policy.arn
}

# Attach Worker IAM policy to the role
resource "aws_iam_policy_attachment" "ocp311_attach_worker_policy" {
  name = "${local.cluster_id}_attach_worker_policy"
  roles = [ aws_iam_role.ocp311_worker_role.name ]
  policy_arn = aws_iam_policy.ocp311_worker_policy.arn
}

# Create Master IAM instance profile
resource "aws_iam_instance_profile" "ocp311_master_profile" {
  name  = "${local.cluster_id}_master_profile"
  role = aws_iam_role.ocp311_master_role.name
}

# Create Worker IAM instance profile
resource "aws_iam_instance_profile" "ocp311_worker_profile" {
  name  = "${local.cluster_id}_worker_profile"
  role = aws_iam_role.ocp311_worker_role.name
}
