# variables.tf

variable "aws_region" {
  description = "AWS 區域"
  type        = string
  default     = "ap-northeast-1"
}

variable "ad_domain_name" {
  description = "AD 與 DHCP 使用的網域名稱"
  type        = string
  default     = "ad.imcloud.com.tw"
}

variable "ad_domain_netbios" {
  description = "AD 的 NetBIOS 名稱"
  type        = string
  default     = "AD"
}

variable "ad_admin_user" {
  description = "AD 管理員帳號"
  type        = string
  default     = "Administrator"
}

variable "ad_admin_password" {
  description = "Simple AD 管理者密碼"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "SSH Key 名稱"
  type        = string
  default     = "albert-terraform"
}

# VPC 相關變數
variable "vpc_cidr" {
  description = "VPC 的 CIDR 區塊"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet 的 CIDR 區塊"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_A_subnet_cidr" {
  description = "Private Subnet A 的 CIDR 區塊"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_B_subnet_cidr" {
  description = "Private Subnet B 的 CIDR 區塊"
  type        = string
  default     = "10.0.3.0/24"
}

# VPN 相關變數
variable "vpn_ami_id" {
  description = "VPN Server 使用的 AMI ID"
  type        = string
  default     = "ami-00a7d6f3b78d70c5a" # Debian 12 (HVM), SSD Volume Type
}

variable "vpn_instance_type" {
  description = "VPN Server 的 EC2 類型"
  type        = string
  default     = "t3.micro"
}

variable "vpn_server_ip" {
  description = "VPN Server 的私有 IP"
  type        = string
  default     = "10.0.1.10"
}

variable "vpn_client_network" {
  description = "VPN client subnet (OpenVPN virtual network)"
  type        = string
  default     = "10.8.0.0"
}

variable "vpn_client_netmask" {
  description = "VPN client subnet mask"
  type        = string
  default     = "255.255.255.0"
}

variable "vpn_client_cidr_suffix" {
  description = "VPN client subnet CIDR suffix"
  type        = string
  default     = "24"
}

# FreeRADIUS 相關變數
variable "radius_ami_id" {
  description = "FreeRADIUS EC2 的 AMI ID"
  type        = string
  default     = "ami-00a7d6f3b78d70c5a" # Debian 12 (HVM), SSD Volume Type
}

variable "radius_instance_type" {
  description = "FreeRADIUS EC2 的機型"
  type        = string
  default     = "t3.micro"
}

variable "radius_a_private_ip" {
  description = "FreeRADIUS Server A 的固定私有 IP"
  type        = string
  default     = "10.0.2.20"
}

variable "radius_b_private_ip" {
  description = "FreeRADIUS Server B 的固定私有 IP"
  type        = string
  default     = "10.0.3.20"
}

variable "radius_secret" {
  description = "VPN 與 RADIUS 驗證密鑰"
  type        = string
  sensitive   = true
  default     = "testing123"
}

# 可用區域相關變數
variable "az_a" {
  description = "可用區域 A"
  type        = string
  default     = "a"
}

variable "az_c" {
  description = "可用區域 C"
  type        = string
  default     = "c"
}

variable "az_d" {
  description = "可用區域 D"
  type        = string
  default     = "d"
}