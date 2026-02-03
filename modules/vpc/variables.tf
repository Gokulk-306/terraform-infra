variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "1" = {
      cidr = "10.0.1.0/24"
      az   = "us-east-2a"
    }
    "2" = {
      cidr = "10.0.2.0/24"
      az   = "us-east-2b"
    }
  }
}

variable "private_subnets" {
  description = "Map of private subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "1" = {
      cidr = "10.0.10.0/24"
      az   = "us-east-2a"
    }
    "2" = {
      cidr = "10.0.20.0/24"
      az   = "us-east-2b"
    }
  }
}