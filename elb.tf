#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#    PUBLIC LOAD BALANCER   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Create Master Public Elastic Load Balancer
resource "aws_lb" "master_elb" {
  name                             = "${local.cluster_id}-master"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = [aws_subnet.public_subnet.id]
  enable_cross_zone_load_balancing = true

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-master-elb"
    )
  )
}

# Create Master Load Balancer listener for port 8443
resource "aws_lb_listener" "listener_master_elb" {
  load_balancer_arn = aws_lb.master_elb.arn
  port              = 8443
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.group_master_elb.arn
    type             = "forward"
  }
}
# Create Master Load Balancer listener for port 80
resource "aws_lb_listener" "listener_http_elb" {
  load_balancer_arn = aws_lb.master_elb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.group_http_elb.arn
    type             = "forward"
  }
}
# Create Master Load Balancer listener for port 443
resource "aws_lb_listener" "listener_https_elb" {
  load_balancer_arn = aws_lb.master_elb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.group_https_elb.arn
    type             = "forward"
  }
}

# Create Master target group for port 8443
resource "aws_lb_target_group" "group_master_elb" {
  name     = "${local.cluster_id}-master-elb-group"
  port     = 8443
  protocol = "TCP"
  vpc_id   = aws_vpc.ocp311.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-master-elb-group"
    )
  )
}
# Create Master target group for port 80
resource "aws_lb_target_group" "group_http_elb" {
  name     = "${local.cluster_id}-http-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.ocp311.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-http-group"
    )
  )
}
# Create Master target group for port 443
resource "aws_lb_target_group" "group_https_elb" {
  name     = "${local.cluster_id}-https-group"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.ocp311.id

  tags = merge(
    local.common_tags,
    map(
      "Name", "${local.cluster_id}-https-group"
    )
  )
}

# Attach Master group to EC2 instance
resource "aws_lb_target_group_attachment" "attachment_master_elb" {
  target_group_arn = aws_lb_target_group.group_master_elb.arn
  target_id        = aws_instance.master.id
  port             = 8443
}
# Attach Master group to EC2 instance
resource "aws_lb_target_group_attachment" "attachment_master_http_elb" {
  target_group_arn = aws_lb_target_group.group_http_elb.arn
  target_id        = aws_instance.master.id
  port             = 80
}
# Attach Master group to EC2 instance
resource "aws_lb_target_group_attachment" "attachment_master_https_elb" {
  target_group_arn = aws_lb_target_group.group_https_elb.arn
  target_id        = aws_instance.master.id
  port             = 443
}
