# Allow SSH access
resource "aws_security_group" "ocp311_ssh" {
  name        = "${local.cluster_id}_ssh"
  description = "Security group to allow SSH"
  vpc_id      = aws_vpc.ocp311.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-ssh-group"
    })
  )
}

# Allow all intra-node communication
resource "aws_security_group" "ocp311_vpc" {
  name        = "${local.cluster_id}_vpc"
  description = "Allow all intra-node communication"
  vpc_id      = aws_vpc.ocp311.id
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-internal-vpc-group"
    })
  )
}

# Allow public ingress
resource "aws_security_group" "ocp311_public_ingress" {
  name        = "${local.cluster_id}_public_ingress"
  description = "Allow public access to HTTP, HTTPS, etc"
  vpc_id      = aws_vpc.ocp311.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP Proxy
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS Proxy
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-public-ingress"
    })
  )
}

# Allow public egress (for yum updates, git, OCP access)
resource "aws_security_group" "ocp311_public_egress" {
  name        = "${local.cluster_id}_public_egress"
  description = "Security group that allows egress to the internet for instances over HTTP and HTTPS."
  vpc_id      = aws_vpc.ocp311.id

  # HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP Proxy
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS Proxy
  egress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # MultiCluster Hub access
  egress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${local.cluster_id}-public-egress"
    })
  )
}
