variable "region" {
  type    = string
  default = "us-east-2"
}
variable "vpc_cidr" {
  type      = string
  sensitive = true
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC_CIDR must be a valid IPv4 CIDR."
  }
}
