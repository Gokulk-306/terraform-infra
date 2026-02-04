# AWS Infrastructure with Terraform - Production Ready

Complete AWS infrastructure setup with VPC, EC2, ALB, Auto Scaling, SSL certificates, and enterprise-grade improvements.

## Architecture

```
Internet → ALB (HTTPS) → EC2 Instances (Private Subnets) → Auto Scaling
                ↓
            CloudWatch Monitoring + SNS Alerts
                ↓
        VPC Flow Logs + Systems Manager
```

## 🚀 **What We Built**

### **Core Infrastructure**
- ✅ **VPC**: 2 public + 2 private subnets across AZs
- ✅ **Security**: Least privilege security groups (SSH removed)
- ✅ **SSL**: ACM certificate with DNS validation
- ✅ **Load Balancing**: ALB with HTTP→HTTPS redirect
- ✅ **Auto Scaling**: Target tracking scaling (60% CPU threshold)
- ✅ **Monitoring**: CloudWatch + SNS email alerts
- ✅ **High Availability**: Multi-AZ deployment

### **🔧 Production Improvements Added**
- ✅ **State Locking**: DynamoDB table prevents concurrent modifications
- ✅ **Cost Optimization**: Single NAT Gateway (saves ~$45/month)
- ✅ **Enhanced Security**: Removed SSH, added Systems Manager access
- ✅ **VPC Flow Logs**: Network traffic monitoring for security
- ✅ **Multi-Environment**: Separate dev/prod configurations
- ✅ **Enhanced Tagging**: Better resource organization and cost tracking
- ✅ **Target Tracking**: Smarter auto scaling vs simple scaling
- ✅ **S3 Backend**: Versioned, encrypted state storage

## 🔐 **State Locking Implementation**

### **Problem Solved**
Without state locking, multiple developers running `terraform apply` simultaneously could:
- Corrupt the state file
- Create duplicate resources
- Cause infrastructure inconsistencies

### **How We Implemented It**

1. **Created DynamoDB Table**:
```hcl
# dynamodb.tf
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"  # Cost-effective
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

2. **Enhanced S3 Backend**:
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "gokulsnew-s3-us-east-2"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"  # 🔒 This enables locking
    encrypt        = true
  }
}
```

3. **S3 Bucket Security**:
```hcl
# s3-backend.tf
- Versioning enabled (state history)
- Server-side encryption (AES256)
- Public access blocked
- Separate state files per environment
```

### **How State Locking Works**
1. **Lock Acquisition**: When `terraform apply` starts, it writes a lock record to DynamoDB
2. **Concurrent Protection**: If another user tries to run Terraform, they get blocked until lock releases
3. **Automatic Release**: Lock automatically releases when operation completes
4. **Error Recovery**: Stale locks can be manually released if needed

## 💰 **Cost Optimizations**

### **Single NAT Gateway**
- **Before**: 2 NAT Gateways ($45.60/month each) = $91.20/month
- **After**: 1 NAT Gateway = $45.60/month
- **Savings**: $45.60/month ($547.20/year)

### **Trade-offs**
- **Pro**: Significant cost savings
- **Con**: Single point of failure for private subnet internet access
- **Mitigation**: Auto Scaling can recreate instances in available AZ

## 🛡️ **Security Enhancements**

### **Removed SSH Access**
```hcl
# Before: SSH allowed from ALB security group
ingress {
  from_port       = 22
  security_groups = [aws_security_group.alb.id]  # ❌ Security risk
}

# After: SSH completely removed
# Access via Systems Manager Session Manager instead
```

### **Added Systems Manager**
```hcl
# EC2 instances now have SSM access
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
```

### **VPC Flow Logs**
```hcl
# Network traffic monitoring
resource "aws_flow_log" "vpc_flow_log" {
  traffic_type = "ALL"  # Captures all network traffic
  vpc_id       = aws_vpc.main.id
}
```

## 📊 **Monitoring Improvements**

### **Target Tracking Auto Scaling**
```hcl
# Before: Simple scaling (manual thresholds)
resource "aws_autoscaling_policy" "scale_up" {
  scaling_adjustment = 1  # Add 1 instance
}

# After: Target tracking (automatic optimization)
resource "aws_autoscaling_policy" "target_tracking" {
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 60.0  # Maintain 60% CPU
  }
}
```

### **Benefits**
- **Smoother scaling**: Gradual adjustments vs sudden jumps
- **Cost efficient**: Scales down automatically when load decreases
- **Better performance**: Maintains consistent response times

## 🏗️ **Multi-Environment Setup**

```
environments/
├── dev/
│   ├── backend.tf      # State: dev/terraform.tfstate
│   ├── terraform.tfvars # Dev-specific values
│   └── main.tf
└── prod/
    ├── backend.tf      # State: prod/terraform.tfstate
    ├── terraform.tfvars # Prod-specific values (higher capacity)
    └── main.tf
```

### **Environment Differences**
| Setting | Dev | Prod |
|---------|-----|------|
| Min Size | 1 | 2 |
| Max Size | 4 | 8 |
| Desired | 2 | 3 |
| Environment Tag | dev | prod |

## 🏷️ **Enhanced Tagging Strategy**

```hcl
default_tags = {
  Environment = var.environment    # dev/prod
  Project     = var.project_name   # webapp
  ManagedBy   = "terraform"        # Infrastructure as Code
  Owner       = "DevOps Team"      # Responsibility
  CostCenter  = "Engineering"      # Cost allocation
}
```

### **Benefits**
- **Cost tracking**: See costs per environment/project
- **Resource management**: Easy filtering and organization
- **Compliance**: Meet enterprise tagging requirements

## 🚀 **Quick Start**

### 1. Prerequisites
```bash
# Install Terraform
# Configure AWS CLI
aws configure
```

### 2. Update Variables
Edit `environments/dev/terraform.tfvars`:
```hcl
domain_name = "yourdomain.com"
key_name    = "your-key-pair"
alert_email = "your-email@example.com"
```

### 3. Deploy Infrastructure
```bash
cd environments/dev

# Initialize (creates S3 bucket and DynamoDB table)
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply
```

### 4. SSL Certificate Setup
After `terraform apply`, get DNS validation records:
```bash
terraform output dns_validation_records
```

Add CNAME record in your DNS provider:
- **Name**: `_abc123...yourdomain.com`
- **Value**: `_xyz789...acm-validations.aws`

### 5. Domain Setup
Add A record in your DNS provider:
- **Name**: `@`
- **Value**: `[ALB DNS from terraform output]`

## 📤 **Outputs**

```bash
terraform output
```

- `alb_dns_name`: Load balancer endpoint
- `dns_validation_records`: SSL validation records for DNS

## 🏗️ **Module Architecture**

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| `vpc` | Network infrastructure | VPC, Subnets, NAT, IGW, Flow Logs |
| `security-group` | Access control | ALB SG, EC2 SG (no SSH) |
| `ec2` | Compute instances | Launch Template, IAM Role, SSM |
| `alb` | Load balancing | ALB, Target Group, Listeners |
| `acm` | SSL certificates | Certificate, DNS validation |
| `autoscaling` | High availability | ASG, Target tracking policy |
| `cloudwatch` | Monitoring | Alarms, SNS, Dashboard |

## 💡 **Key Learnings**

### **State Management**
- **Always use remote state** for team collaboration
- **Enable state locking** to prevent corruption
- **Separate state files** per environment
- **Version your state bucket** for rollback capability

### **Security Best Practices**
- **Remove SSH access** from production instances
- **Use Systems Manager** for secure access
- **Enable VPC Flow Logs** for network monitoring
- **Apply least privilege** security groups

### **Cost Optimization**
- **Single NAT Gateway** for non-critical workloads
- **Target tracking scaling** for efficient resource usage
- **Proper tagging** for cost allocation
- **Right-size instances** based on actual usage

### **Operational Excellence**
- **Multi-environment setup** for safe deployments
- **Comprehensive monitoring** with CloudWatch
- **Automated scaling** based on metrics
- **Infrastructure as Code** for consistency

## 🔧 **Troubleshooting**

### **State Lock Issues**
```bash
# If state is locked and operation failed
terraform force-unlock <LOCK_ID>
```

### **Backend Migration**
```bash
# When changing backend configuration
terraform init -migrate-state
```

### **Access EC2 Instances**
```bash
# Use Systems Manager instead of SSH
aws ssm start-session --target <instance-id>
```

## 📈 **Next Steps**

1. **Add Database Layer**: RDS with Multi-AZ
2. **Implement WAF**: Web Application Firewall
3. **Add CloudFront**: CDN for static assets
4. **Set up CI/CD**: Automated deployments
5. **Add Secrets Manager**: Secure credential storage
6. **Implement Backup Strategy**: Cross-region backups

---

**Infrastructure Status**: ✅ Production Ready
**Security**: ✅ Hardened
**Cost**: ✅ Optimized
**Monitoring**: ✅ Comprehensive