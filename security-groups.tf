/* Default security group */

/* Security group for the bastion server */
resource "aws_security_group" "bastion" {
  name = "sg_nat"
  description = "Security group for bastion instances that allows SSH and VPN traffic from internet"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.private_cidr_blocks["0"]}", "${var.private_cidr_blocks["1"]}", "${var.private_cidr_blocks["2"]}"]
  }
}

/* Security group for the webserver servers */
resource "aws_security_group" "webserver" {
  name = "sg_webserver"
  description = "Security group for webserver instances that allows web traffic inside the VPC"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = ["${aws_security_group.elb_webserver.id}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress { # allow icmp outbound
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # allow udp port 53 outbound for dns queries
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # allow port 80 outbound for yum updates
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # allow port 443 outbound for yum updates
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # allow port 11371 outbound for gpg keys
    from_port = 11371
    to_port = 11371
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Security group for the web */
resource "aws_security_group" "elb_webserver" {
  name = "elb-webserver"
  description = "Security group for web that allows web traffic from internet"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr_blocks["0"]}", "${var.private_cidr_blocks["1"]}", "${var.private_cidr_blocks["2"]}"]
  }

  tags {
    Name = "elb-webserver"
  }
}
