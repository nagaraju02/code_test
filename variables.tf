variable "region" {
  default = "us-west-2"
}
variable "aws_profile" {
  default = "nagaraj"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "environment" {
  default = "qa"
}
variable "publicsubnet_cidr1" {
  default = "10.0.1.0/24"
}
variable "publicsubnet_cidr2" {
  default = "10.0.2.0/24"
}

variable "keypair_name" {
  default = "codetest"
}