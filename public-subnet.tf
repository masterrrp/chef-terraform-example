/* public subnets */
resource "aws_subnet" "public" {
  count = "${length(split(",", lookup(var.availability_zones, var.region)))}"
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${lookup(var.public_cidr_blocks, count.index)}"
  availability_zone = "${element(split(",", lookup(var.availability_zones, var.region)), count.index)}"
}



/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

/* Associate the routing table to public subnets */
resource "aws_route_table_association" "public0" {
  subnet_id = "${aws_subnet.public.0.id}"
  route_table_id = "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
}

resource "aws_route_table_association" "public1" {
  subnet_id = "${aws_subnet.public.1.id}"
  route_table_id = "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
}

resource "aws_route_table_association" "public2" {
  subnet_id = "${aws_subnet.public.2.id}"
  route_table_id = "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
}



/* Internet and NAT gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_eip" "nat_gw" { vpc = true }
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_gw.id}"
  subnet_id = "${aws_subnet.public.0.id}"
}
