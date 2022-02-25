# VPC
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  assign_generated_ipv6_cidr_block = false
  instance_tenancy                 = "default" # default | dedicated | host

  tags = merge(
    {
      "Name" = "${var.project}-vpc"
    },
    var.tags
  )
}


# Subnet(s)
# Public subnets
resource "aws_subnet" "this" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name"                                         = "${var.project}-eks-snet",
      "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    },
    var.tags
  )
}


# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.project}-igw"
    },
    var.tags
  )

  depends_on = [aws_vpc.this]
}


# NAT Gateway
resource "aws_eip" "nat" {
  count = 2
  vpc = true

  tags = merge(
    {
      "Name" = "${var.project}-ngw"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count = 2
  allocation_id      = element(aws_eip.nat.*.id, count.index)
  subnet_id      = element(aws_subnet.this.*.id, count.index)

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}


# Route Table(s)
# Route Table: Default
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = merge(
    {
      "Name" = "${var.project}-Default-rt"
    },
    var.tags
  )

  depends_on = [aws_vpc.this]
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.project}-Public-rt"
    },
    var.tags
  )
}

# Route to Internet (Internet Gateway)
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.this.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"

  timeouts {
    create = "5m"
  }
}

# Route Table - Subnet associations
resource "aws_route_table_association" "this" {
  count = 2

  route_table_id = aws_route_table.this.id
  subnet_id      = element(aws_subnet.this.*.id, count.index)
}


# Security Group(s)
# Security Group: Default
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.project}-Default-sg"
    },
    var.tags
  )

  depends_on = [aws_vpc.this]
}

# Security Group
resource "aws_security_group" "this" {
  name        = var.project
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "${var.project}-sg"
    },
    var.tags
  )
}

# Security Group - Rules
# http
resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = [var.office_cidr]
  description       = "Allow http"
}

# https
resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.office_cidr]
  description       = "Allow https"
}
