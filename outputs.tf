output "bastion.ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.asg_webserver.id}"
}

output "elb_name" {
  value = "${aws_elb.elb_webserver.dns_name}"
}
