
/* private subnets */
resource "aws_subnet" "private" {
  count = "${length(split(",", lookup(var.availability_zones, var.region)))}"
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${lookup(var.private_cidr_blocks, count.index)}"
  availability_zone = "${element(split(",", lookup(var.availability_zones, var.region)), count.index)}"
}



/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
}

/* Associate the routing table to public subnets */
resource "aws_route_table_association" "private0" {
  subnet_id = "${aws_subnet.private.0.id}"
  route_table_id = "${aws_route_table.private.id}"
  depends_on = ["aws_route_table.private"]
}

resource "aws_route_table_association" "private1" {
  subnet_id = "${aws_subnet.private.1.id}"
  route_table_id = "${aws_route_table.private.id}"
  depends_on = ["aws_route_table.private"]
}

resource "aws_route_table_association" "private2" {
  subnet_id = "${aws_subnet.private.2.id}"
  route_table_id = "${aws_route_table.private.id}"
  depends_on = ["aws_route_table.private"]
}
