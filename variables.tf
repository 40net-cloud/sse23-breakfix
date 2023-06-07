variable "prefix" {
    type = string
}

variable "az_region" {
    type = string
    default = "West Europe"
}

variable "az_tags" {
    type = map(string)
    default = {}
}

variable "aws_region" {
    type = string
    default = "eu-central-1"
}

variable "flex_serials" {
    type = list(string)
    default = []
}

variable "az_elb_ports" {
    type = map(string)
    default = {"rdp": "Tcp:3398", "ike": "Udp:500", "ipsec": "Udp:4500"}
}

variable "aws_zones" {
    type = list(string)
    default = ["a", "b"]
}

variable "fgt_asn_az" {
    type = number
    default = 65501
}

variable "fgt_asn_aws" {
    type = number
    default = 65501
}

variable "az_rg_name" {
    type = string
}
