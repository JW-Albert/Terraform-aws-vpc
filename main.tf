# main.tf

# ==========================================
# Provider Configuration
# ==========================================
provider "aws" {
  region = var.aws_region
}

# ==========================================
# VPC and DHCP Configuration
# ==========================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name          = var.ad_domain_name
  domain_name_servers  = ["AmazonProvidedDNS"]
  ntp_servers          = ["169.254.169.123"]
  tags = {
    Name = "main-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

# ==========================================
# Subnet Configuration
# ==========================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${var.az_a}"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_A" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_A_subnet_cidr
  availability_zone = "${var.aws_region}${var.az_c}"
  tags = {
    Name = "private-subnet-A"
  }
}

resource "aws_subnet" "private_B" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_B_subnet_cidr
  availability_zone = "${var.aws_region}${var.az_d}"
  tags = {
    Name = "private-subnet-B"
  }
}

# ==========================================
# Gateway Configuration
# ==========================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# ==========================================
# Route Table Configuration
# ==========================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_A" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-A"
  }
}

resource "aws_route_table_association" "private_A_assoc" {
  subnet_id      = aws_subnet.private_A.id
  route_table_id = aws_route_table.private_A.id
}

resource "aws_route_table" "private_B" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-B"
  }
}

resource "aws_route_table_association" "private_B_assoc" {
  subnet_id      = aws_subnet.private_B.id
  route_table_id = aws_route_table.private_B.id
}

# ==========================================
# Security Groups Configuration
# ==========================================
# Simple AD
resource "aws_security_group" "ad_sg" {
  name        = "simplead-sg"
  description = "Allow LDAP ports for directory service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simplead-sg"
  }
}

# VPN Server
resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "Allow VPN UDP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg"
  }
}

# FreeRADIUS Server A
resource "aws_security_group" "radius_sg_A" {
  name        = "radius-sg-A"
  description = "Allow RADIUS UDP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "radius-sg-A"
  }
}

# FreeRADIUS Server B
resource "aws_security_group" "radius_sg_B" {
  name        = "radius-sg-B"
  description = "Allow RADIUS UDP in second AZ"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1812
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "radius-sg-B"
  }
}

# ==========================================
# Instance Configuration
# ==========================================
# VPN Server
resource "aws_instance" "vpn" {
  ami                         = var.vpn_ami_id
  instance_type               = var.vpn_instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]
  associate_public_ip_address = true
  private_ip                  = var.vpn_server_ip

  tags = {
    Name = "vpn-server"
  }

  user_data = templatefile("${path.module}/scripts/install_openvpn.tftpl", {
    vpn_client_network     = var.vpn_client_network
    vpn_client_netmask     = var.vpn_client_netmask
    vpn_client_cidr_suffix = var.vpn_client_cidr_suffix
    radius_a_private_ip    = var.radius_a_private_ip
    radius_b_private_ip    = var.radius_b_private_ip
    radius_secret          = var.radius_secret
    dns                    = aws_directory_service_directory.simple_ad.dns_ip_addresses,
    ad_domain_name         = var.ad_domain_name
  })
}

# FreeRADIUS Server A
resource "aws_instance" "radius_A" {
  ami                    = var.radius_ami_id
  instance_type          = var.radius_instance_type
  subnet_id              = aws_subnet.private_A.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.radius_sg_A.id]
  private_ip             = var.radius_a_private_ip

  tags = {
    Name = "freeradius-server-A"
  }

  user_data = templatefile("${path.module}/scripts/install_freeradius_ad.tftpl", {
    ad_domain_name      = var.ad_domain_name,
    ad_domain_netbios   = var.ad_domain_netbios,
    ad_admin_user       = var.ad_admin_user,
    ad_admin_password   = var.ad_admin_password,
    vpn_server_ip       = var.vpn_server_ip,
    radius_secret       = var.radius_secret
  })
}

# FreeRADIUS Server B
resource "aws_instance" "radius_B" {
  ami                    = var.radius_ami_id
  instance_type          = var.radius_instance_type
  subnet_id              = aws_subnet.private_B.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.radius_sg_B.id]
  private_ip             = var.radius_b_private_ip

  tags = {
    Name = "freeradius-server-B"
  }

  user_data = templatefile("${path.module}/scripts/install_freeradius_ad.tftpl", {
    ad_domain_name      = var.ad_domain_name,
    ad_domain_netbios   = var.ad_domain_netbios,
    ad_admin_user       = var.ad_admin_user,
    ad_admin_password   = var.ad_admin_password,
    vpn_server_ip       = var.vpn_server_ip,
    radius_secret       = var.radius_secret
  })
}

# ==========================================
# Directory Service Configuration
# ==========================================
resource "aws_directory_service_directory" "simple_ad" {
  name     = var.ad_domain_name
  password = var.ad_admin_password
  size     = "Small"
  type     = "SimpleAD"
  vpc_settings {
    vpc_id     = aws_vpc.main.id
    subnet_ids = [aws_subnet.private_A.id, aws_subnet.private_B.id]
  }
  tags = {
    Name = "simple-ad"
  }
}