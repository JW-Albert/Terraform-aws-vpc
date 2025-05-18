# imcloud-aws-vpc

這個 Terraform 專案用於在 AWS 上建立一個完整的 VPC 基礎設施，包含以下主要元件：

## 基礎設施架構

### 網路架構
- VPC (CIDR: 10.0.0.0/16)
  - Public Subnet (10.0.1.0/24)    - 可用區域 A (ap-northeast-1a)
  - Private Subnet A (10.0.2.0/24) - 可用區域 C (ap-northeast-1c)
  - Private Subnet B (10.0.3.0/24) - 可用區域 D (ap-northeast-1d)

### AMI ID 對照表
| Name                                           | ID                    |
| ---------------------------------------------- | --------------------- |
| Debian 12 (HVM), SSD Volume Type               | ami-00a7d6f3b78d70c5a |
| Ubuntu Server 24.04 LTS (HVM), SSD Volume Type | ami-026c39f4021df9abe |

### 網路與安全組設定

#### VPC 設定
- CIDR 區塊: 10.0.0.0/16
- DNS 主機名稱: 啟用
- DNS 解析: 啟用
- 子網路 CIDR 區塊:
  - Public Subnet: 10.0.1.0/24 (ap-northeast-1a)
  - Private Subnet A: 10.0.2.0/24 (ap-northeast-1c)
  - Private Subnet B: 10.0.3.0/24 (ap-northeast-1d)

#### VPC 架構圖
```
ap-northeast-1 (東京區域)
+------------------------------------------+
|                                          |
|  +----------------+  +----------------+  |
|  |   Public Subnet|  | Private Subnet |  |
|  |  10.0.1.0/24   |  | A 10.0.2.0/24  |  |
|  |  ap-northeast-1a|  | ap-northeast-1c|  |
|  +----------------+  +----------------+  |
|                                          |
|  +----------------+                      |
|  | Private Subnet |                      |
|  | B 10.0.3.0/24  |                      |
|  | ap-northeast-1d|                      |
|  +----------------+                      |
|                                          |
+------------------------------------------+

圖例:
- Public Subnet: 可從網際網路直接訪問
- Private Subnet: 僅可通過 NAT Gateway 訪問網際網路
- 所有子網路間可以互相通訊
```

#### 安全組設定

##### Simple AD 安全組
- 入站規則:
  - TCP 53 (DNS)
  - UDP 53 (DNS)
  - TCP 88 (Kerberos)
  - UDP 88 (Kerberos)
  - TCP 389 (LDAP)
  - TCP 445 (SMB)
  - TCP 636 (LDAPS)
  - TCP 3268 (LDAP GC)
  - TCP 3269 (LDAPS GC)
  - TCP 3389 (RDP)
  - TCP 9389 (AD Web Services)
- 出站規則:
  - 允許所有流量 (0.0.0.0/0)

##### OpenVPN 安全組
- 入站規則:
  - TCP 22 (SSH)
  - UDP 1194 (OpenVPN)
  - TCP 443 (HTTPS)
- 出站規則:
  - 允許所有流量 (0.0.0.0/0)

##### FreeRADIUS 安全組
- 入站規則:
  - TCP 22 (SSH)
  - UDP 1812 (RADIUS Authentication)
  - UDP 1813 (RADIUS Accounting)
  - TCP 1812 (RADIUS Authentication)
  - TCP 1813 (RADIUS Accounting)
- 出站規則:
  - 允許所有流量 (0.0.0.0/0)

#### 路由表設定
- Public Subnet:
  - 本地路由 (10.0.0.0/16)
  - 網際網路閘道 (0.0.0.0/0)
- Private Subnet A/B:
  - 本地路由 (10.0.0.0/16)
  - NAT 閘道 (0.0.0.0/0)

### 主要服務
- Simple AD 目錄服務
- OpenVPN 伺服器
- FreeRADIUS 認證伺服器 (雙可用區域部署)

## 前置需求

1. 安裝必要工具
   - Terraform (>= 1.0.0)
   - AWS CLI
   - 設定 AWS 認證

2. 準備變數
   - 建立 `terraform.tfvars` 文件，設定以下必要變數：
     ```hcl
     ad_admin_password = "your-ad-password"
     radius_secret     = "your-radius-secret"
     ```

## 使用方式

### 設定臨時變數，儲存 AWS Access
```bash
set AWS_ACCESS_KEY_ID=
set AWS_SECRET_ACCESS_KEY=
```

### 初始化 Terraform
```bash
terraform init
```

### 預覽變更
```bash
terraform plan
```

### 部署基礎設施
```bash
terraform apply
```

### 查看輸出資訊
```bash
terraform output
```

### 清理資源
```bash
terraform destroy
```

## 輸出資訊

部署完成後，可以查看以下重要資訊：

### VPC 相關
- VPC ID
- VPC CIDR 區塊
- 子網路 ID (Public, Private A, Private B)

### 安全群組
- Simple AD 安全群組 ID
- VPN 安全群組 ID
- FreeRADIUS 安全群組 ID (A, B)

### 實例資訊
- VPN 伺服器公有 IP
- VPN 伺服器私有 IP
- FreeRADIUS 伺服器私有 IP (A, B)

### Simple AD 資訊
- 目錄服務 ID
- DNS IP 位址
- 管理介面 URL

## 注意事項

1. 安全性
   - 請確保 `ad_admin_password` 和 `radius_secret` 使用強密碼
   - 建議定期更換密碼
   - 請妥善保管 `terraform.tfvars` 文件

2. 成本考量
   - Simple AD 會產生持續性費用
   - NAT Gateway 會產生持續性費用
   - EC2 實例會產生持續性費用

3. 維護建議
   - 定期更新 AMI
   - 監控資源使用情況
   - 定期備份重要配置

## 故障排除

1. 如果遇到 Simple AD 建立失敗：
   - 確認 VPC 設定正確
   - 確認子網路 CIDR 不重疊
   - 檢查安全群組設定

2. 如果 VPN 連線問題：
   - 確認安全群組允許 UDP 1194
   - 檢查 FreeRADIUS 服務狀態
   - 確認 AD 整合設定

## 授權

MIT License