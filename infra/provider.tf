terraform {terraform {

  required_providers {  required_providers {

    aws = {    aws = {

      source  = "hashicorp/aws"      source  = "hashicorp/aws"

      version = "~> 5.0"      version = "~> 5.0"

    }    }

  }  }

  required_version = ">= 1.3.0"  required_version = ">= 1.3.0"

}}



provider "aws" {provider "aws" {

  region = var.aws_region  region = var.aws_region

}}