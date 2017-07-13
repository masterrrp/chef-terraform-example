resource "aws_elb" "elb_webserver" {
  name = "webserver-elb"

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 10
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  subnets = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.elb_webserver.id}"]

  tags {
    Name = "webserver-elb"
  }
}

resource "aws_autoscaling_group" "asg_webserver" {
  lifecycle { create_before_destroy = true }
  availability_zones = ["${split(",", lookup(var.availability_zones, var.region))}"]
  name = "asg-webserver-${aws_launch_configuration.lc_webserver.name}"
  max_size = 5
  min_size = 2
  wait_for_elb_capacity = 2
  desired_capacity = 2
  health_check_grace_period = 60
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.lc_webserver.id}"
  load_balancers = ["${aws_elb.elb_webserver.id}"]
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]
  tag {
    key = "Name"
    value = "webserver"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_webserver" {
  lifecycle { create_before_destroy = true }
  image_id = "${var.ami}"
  instance_type = "c4.large"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = ["${aws_security_group.webserver.id}"]
}

resource "aws_autoscaling_policy" "scale_out_webserver" {
  name                   = "webserver-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.asg_webserver.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_out_webserver" {
  alarm_name = "webserver-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "80"
  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_out_webserver.arn}"]
}

resource "aws_autoscaling_policy" "scale_in_webserver" {
  name                   = "webserver-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.asg_webserver.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_in_webserver" {
  alarm_name = "webserver-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "60"
  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_in_webserver.arn}"]
}
