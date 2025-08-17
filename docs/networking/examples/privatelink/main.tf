terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region to deploy the endpoint"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "Target VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the endpoint"
  type        = string
}

variable "service_name" {
  description = "PrivateLink service name provided by AirBridge"
  type        = string
}

resource "aws_security_group" "endpoint" {
  name        = "airbridge-privatelink"
  description = "Allow HTTPS to AirBridge PrivateLink"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "airbridge" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = false
}

