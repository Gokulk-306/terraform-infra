# AWS Infrastructure with Terraform

Complete AWS infrastructure setup with VPC, EC2, ALB, Auto Scaling, and SSL certificates.

## Architecture

```
Internet → ALB (HTTPS) → EC2 Instances (Private Subnets) → Auto Scaling
                ↓
            CloudWatch Monitoring + SNS Alerts
```

## Features

- ✅ **VPC**: 2 public + 2 private subnets across AZs
- ✅ **Security**: Least privilege security groups
- ✅ **SSL**: ACM certificate with DNS validation
- ✅ **Load Balancing**: ALB with HTTP→HTTPS redirect
- ✅ **Auto Scaling**: CPU-based scaling (60% threshold)
- ✅ **Monitoring**: CloudWatch + SNS email alerts
- ✅ **High Availability**: Multi-AZ deployment

## Quick Start

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

### 3. Deploy
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 4. SSL Certificate Setup
After `terraform apply`, get DNS validation records:
```bash
terraform output
```

Add CNAME records in GoDaddy:
- **Name**: `_abc123...yourdomain.com`
- **Value**: `_xyz789...acm-validations.aws`

### 5. Domain Setup
In GoDaddy DNS, add A record:
- **Name**: `@`
- **Value**: `[ALB DNS from terraform output]`

## Outputs

- `alb_dns_name`: Load balancer endpoint
- `dns_validation_records`: SSL validation records for GoDaddy

## Modules

| Module | Purpose |
|--------|---------|
| `vpc` | Network infrastructure |
| `security-group` | Access control |
| `ec2` | Compute instances |
| `alb` | Load balancing |
| `acm` | SSL certificates |
| `autoscaling` | High availability |
| `cloudwatch` | Monitoring |

## Cost Optimization

- Uses `t3.micro` instances (free tier eligible)
- ACM certificates are **FREE**
- Auto scaling prevents over-provisioning

## Security

- EC2 instances in private subnets
- Security groups with least privilege
- IAM roles instead of access keys
- HTTPS enforcement

## Monitoring

- CPU utilization alerts at 70%
- Email notifications via SNS
- CloudWatch dashboard
- Auto scaling at 60% CPU