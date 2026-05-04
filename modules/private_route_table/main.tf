resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

resource "aws_route_table_association" "private_assoc" {
  count = length(var.subnet_ids)

  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.private_rt.id
}
