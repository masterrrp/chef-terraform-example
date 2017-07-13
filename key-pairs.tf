resource "aws_key_pair" "deployer" {
  key_name   = "chef_terraform_example"
  public_key = "${file("ssh_keys/id_rsa_example.pub")}"
}
