variable "name" {
    description = "The name of the VPC"
    type = string
    default = "my-vpc"
}

variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type = string
    default =  ""
}

variable "enable_dns_support" {
    description = "A boolean flag to enable/disable DNS support in the VPC"
    type = bool
    default = true
}

variable "enable_dns_hostnames" {
    description = "A boolean flag to enable/disable DNS hostnames in the VPC"
    type = bool
    default = true
}

variable "tags" {
    description = "A map of tags to assign to the VPC"
    type = map(string)
    default = {}
}

variable "public_subnet_cidrs" {
    description = "A list of CIDR blocks for public subnets"
    type = list(string)
    default = []
}

variable "private_subnet_cidrs" {
    description = "A list of CIDR blocks for private subnets"
    type = list(string)
    default = []
}

variable "public_subnet_azs" {
    description = "A list of availability zones for public subnets"
    type = list(string)
    default = []
}

variable "private_subnet_azs" {
    description = "A list of availability zones for private subnets"
    type = list(string)
    default = []
}

variable "create_nat_gateway" {
    description = "A boolean flag to create NAT gateways in private subnets"
    type = bool
    default = false
}

variable "public_subnet_tags" {
    description = "A map of tags to assign to public subnets"
    type = map(string)
    default = {}
}

variable "private_subnet_tags" {
    description = "A map of tags to assign to private subnets"
    type = map(string)
    default = {}
}