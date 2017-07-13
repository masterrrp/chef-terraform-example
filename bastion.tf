/* bastion/VPN server */
resource "aws_eip" "bastion" {
    instance = "${aws_instance.bastion.id}"
    vpc = true
}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"

  # deploy the bastion instance into the first availability zone
  subnet_id = "${aws_subnet.public.0.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  key_name = "${aws_key_pair.deployer.key_name}"
  source_dest_check = false
  tags = {
    Name = "bastion"
  }
}
