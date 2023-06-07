module "aws" {
    source = "./aws-transitgwyconnect"

    license_type = "byol"
    region = var.aws_region
    az1 = "${var.aws_region}${var.aws_zones[0]}"
    az2 = "${var.aws_region}${var.aws_zones[1]}"
    size = "c6g.xlarge"
    arch = "arm"
    flex_tokens = ["",""]//slice(local.flex_tokens, 2, 4)
    keyname = aws_key_pair.oneforall.key_name
    vpn_peer = azurerm_public_ip.elb.ip_address
    psksecret = "alamakota"
    fgt_asn = var.fgt_asn_aws
    fgt_asn_az = var.fgt_asn_az
    csvpccidr = "10.200.0.0/16"
    cs2vpccidr = "10.201.0.0/16"
    csprivatecidraz1 = "10.200.200.0/24"
    cs2privatecidraz1 = "10.201.201.0/24"
}

resource "aws_key_pair" "oneforall" {
    key_name = "oneforall"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWeZoRFcGfAmTTpkW9PxON4A+k3gpOWBV2NTQgrI2lR4+GR99ZTxtCH82PYgIxpyA8w0FkVUBTzKUHeQRfW6+SRno+HsVt//ToSf/vpaSRvQvLk71//HUGDCamvIKdiyp6V+AhhL2fvI3BVjIOU1JmwLsK1cnwxV7JC5lrsOg2DOCPdcXIPKA4/tfMaArkjbINFPmbkXUDH1qtDB+7J9SuYJEaldybrGO4xJUxuHhw/qsszbW0GgHgmxfAK0aKfXCyugpAj0LD84412AwT9W9Jvz14Da0B4cZz3BztfgC5ViHbD3aYpie1u7lSD0QtzlnbBVS2hTp0xo4qKkcUGZXGvVkSs+xWU57JMWOFHDXSCY4WGj68QGAxUoEdeIcD195y75TxIr87bmdscyJ/c0lrfuLeNIAOxFd/8SbunCUay/jhpXsTmLFIIKYDyn53R/wErwG0fGIbZrDbsbnlkhyt+x/ehbsJOQVau+gwYi02t7L30eCAi3vZpDQsNv7hEp8= me@40net.cloud"
}