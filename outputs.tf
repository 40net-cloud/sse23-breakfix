output "AZ_FGT1" {
    value = "sse:${random_string.pwd.result}@${azurerm_public_ip.mgmt[0].ip_address}"
}
/*output "AZ_FGT1_token" {
    value = local.flex_tokens[0]
}*/
output "AZ_FGT2" {
    value = "sse:${random_string.pwd.result}@${azurerm_public_ip.mgmt[1].ip_address}"
}
/*output "AZ_FGT2_token" {
    value = local.flex_tokens[1]
}*/
output "AWS_FGT1" {
    value = "admin:${module.aws.FGT-Password}@${module.aws.FGTPrimaryIP}"
}
/*output "AWS_FGT1_token" {
    value = local.flex_tokens[2]
}*/
output "AWS_FGT2" {
    value = "admin:${module.aws.FGT-Password}@${module.aws.FGTSecondaryIP}"
}
/*output "AWS_FGT2_token" {
    value = local.flex_tokens[3]
}*/
output "Jump_host" {
    value = azurerm_public_ip.elb.ip_address
}