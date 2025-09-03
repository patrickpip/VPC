resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = merge({Name = var.name},var.tags)
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = merge({Name = "${var.name}-igw"}, var.tags)
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = length(var.public_subnet_azs) > 0 ? element(var.public_subnet_azs,count.index): null
    map_public_ip_on_launch = true
    tags = merge({Name = "${var.name}-public-${count.index + 1}"}, var.tags,var.public_subnet_tags)
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = length(var.private_subnet_azs) > 0 ? element(var.private_subnet_azs,count.index): null
    map_public_ip_on_launch = false
    tags = merge({Name = "${var.name}-private-${count.index + 1}"}, var.tags,var.private_subnet_tags) 
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = merge({Name = "${var.name}-public-rt"}, var.tags)
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    count = var.create_nat_gateway ? 1 : 0
    tags = merge({Name = "${var.name}-nat-${count.index + 1}"}, var.tags)
    depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat" {
    count = var.create_nat_gateway ? 1 : 0
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index % length(aws_subnet.public)].id
    tags = merge({Name = "${var.name}-nat-${count.index + 1}"}, var.tags)
    depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_route_table" "private" {
    count = var.create_nat_gateway ? 1 : 0
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
    tags = merge({Name = "${var.name}-private-rt-${count.index + 1}"}, var.tags)
}

resource "aws_route_table_association" "private" {
    count = var.create_nat_gateway ? length(aws_subnet.private) : 0
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}