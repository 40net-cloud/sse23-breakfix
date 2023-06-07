resource "azurerm_network_interface" "ext" {
    count                = 2

    name                 = "nic-ext-fgt${count.index+1}"
    location             = var.az_region
    resource_group_name  = var.az_rg_name
    enable_ip_forwarding = true
    enable_accelerated_networking = true

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.ext.id
        private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_network_interface" "int" {
    count                = 2

    name                 = "nic-int-fgt${count.index+1}"
    location             = var.az_region
    resource_group_name  = var.az_rg_name
    enable_ip_forwarding = true
    enable_accelerated_networking = true

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.int.id
        private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_network_interface" "mgmt" {
    count = 2
    name                = "nic-mgmt-fgt${count.index+1}"
    location            = var.az_region
    resource_group_name = var.az_rg_name
    enable_accelerated_networking = true

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.mgmt.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.mgmt[count.index].id
    }
}

resource "azurerm_public_ip" "mgmt" {
    count = 2
    name = "${var.prefix}-fgt${count.index+1}-mgmt-pip"
    location = var.az_region
    resource_group_name = var.az_rg_name
    allocation_method = "Static"
    zones = [count.index+1]
    sku = "Standard"
}

resource "azurerm_linux_virtual_machine" "fgts" {
    count = 2
    lifecycle {
        ignore_changes = [custom_data]
    }

  name                    = "${var.prefix}-fgt${count.index+1}"
  location                = var.az_region
  resource_group_name     = var.az_rg_name
  size                    = "Standard_F4s"
  zone                    = count.index+1
  network_interface_ids = [
      azurerm_network_interface.ext[count.index].id,
      azurerm_network_interface.int[count.index].id,
      azurerm_network_interface.mgmt[count.index].id,
  ]

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "fortinet_fg-vm"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
/*
  storage_data_disk {
    name              = "${var.PREFIX}-B-FGT-VM-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }
*/
    computer_name  = "az-fgt${count.index+1}"
    admin_username = "sse"
    admin_password = random_string.pwd.result
    disable_password_authentication = false
    custom_data    = base64encode( templatefile( "./az_fgt_config.tftpl", {
        "flex_token": "" //local.flex_tokens[count.index+0],
        "ha_gateway": cidrhost(azurerm_subnet.mgmt.address_prefixes[0], 1),
        "ha_priority": "${10-count.index}",
        "ha_peer_ip": azurerm_network_interface.mgmt[(count.index+1)%2].private_ip_address,
        "port3_ip_mask": "${azurerm_network_interface.mgmt[count.index].private_ip_address}/28",
        "elb_pip": azurerm_public_ip.elb.ip_address,
        "bgp_az_peers": azurerm_route_server.ars.virtual_router_ips,
        "bgp_az_asn": azurerm_route_server.ars.virtual_router_asn,
        "fgt_asn_az": tostring(var.fgt_asn_az)
        "fgt_asn_aws": tostring(var.fgt_asn_aws)
        "ipsec_aws_peer": module.aws.FGTPublicIP
        "psksecret": "alamakota"
    }))
    boot_diagnostics {}
}

data "azurerm_resource_group" "my" {
  name = var.az_rg_name
}


resource "azurerm_role_assignment" "fgt" {
  role_definition_name = "Reader"
  scope = data.azurerm_resource_group.my.id
  principal_id = azurerm_linux_virtual_machine.fgts[0].identity[0].principal_id
}
