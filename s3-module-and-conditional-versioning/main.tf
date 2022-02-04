terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "3.71.0"
		}
	}	
}

provider "aws" {
	region = "eu-west-2"
}

module "s3" {
	source = "./modules/s3"
	versioning = "enabled"
}
