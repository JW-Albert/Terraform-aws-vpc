# outputs.tf

# VPC 相關輸出
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR 區塊"
  value       = aws_vpc.main.cidr_block
}

# 子網路相關輸出
output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_a_id" {
  description = "Private Subnet A ID"
  value       = aws_subnet.private_A.id
}

output "private_subnet_b_id" {
  description = "Private Subnet B ID"
  value       = aws_subnet.private_B.id
}

# 安全群組相關輸出
output "ad_sg_id" {
  description = "Simple AD Security Group ID"
  value       = aws_security_group.ad_sg.id
}

output "vpn_sg_id" {
  description = "VPN Security Group ID"
  value       = aws_security_group.vpn_sg.id
}

output "radius_sg_a_id" {
  description = "FreeRADIUS Server A Security Group ID"
  value       = aws_security_group.radius_sg_A.id
}

output "radius_sg_b_id" {
  description = "FreeRADIUS Server B Security Group ID"
  value       = aws_security_group.radius_sg_B.id
}

# 實例相關輸出
output "vpn_public_ip" {
  description = "VPN Server 的公有 IP"
  value       = aws_instance.vpn.public_ip
}

output "vpn_private_ip" {
  description = "VPN Server 的私有 IP"
  value       = aws_instance.vpn.private_ip
}

output "radius_a_private_ip" {
  description = "FreeRADIUS Server A 的私有 IP"
  value       = aws_instance.radius_A.private_ip
}

output "radius_b_private_ip" {
  description = "FreeRADIUS Server B 的私有 IP"
  value       = aws_instance.radius_B.private_ip
}

# Simple AD 相關輸出
output "directory_id" {
  description = "Simple AD Directory ID"
  value       = aws_directory_service_directory.simple_ad.id
}

output "directory_dns" {
  description = "Simple AD DNS IP 位址"
  value       = aws_directory_service_directory.simple_ad.dns_ip_addresses
}

output "directory_access_url" {
  description = "Simple AD 管理介面 URL"
  value       = aws_directory_service_directory.simple_ad.access_url
}