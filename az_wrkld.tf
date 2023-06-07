
/*
resource "azurerm_linux_virtual_machine" "prx" {
  name                = "${var.prefix}-az-proxy"
  resource_group_name = var.az_rg_name
  location            = azurerm_resource_group.sse.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.prx.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }
}
*/

resource "azurerm_network_interface" "win" {
    name = "${var.prefix}-nic-win"
    location = var.az_region
    resource_group_name = var.az_rg_name

    ip_configuration {
        name = "ipconfig1"
        subnet_id = azurerm_subnet.wrkld.id
        private_ip_address_allocation = "Static"
        private_ip_address = "10.100.100.100"
    }
}

resource "azurerm_network_security_group" "rdp" {
    name = "${var.prefix}-nsg-rdp"
    location = var.az_region
    resource_group_name = var.az_rg_name

    security_rule {
        name                    = "allow-rdp"
        protocol                = "Tcp"
        source_address_prefix   = "*"
        source_port_range       = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges = [
            3389
        ]
        access                  = "Allow"
        priority = 100
        direction = "Inbound"
    }
}

resource "azurerm_network_interface_security_group_association" "rdp" {
  network_interface_id      = azurerm_network_interface.win.id
  network_security_group_id = azurerm_network_security_group.rdp.id
}

resource "azurerm_windows_virtual_machine" "win" {
  name                = "${var.prefix}-win"
  resource_group_name = var.az_rg_name
  location            = var.az_region
  size                = "Standard_B2ms"
  admin_username      = "sse"
  admin_password      = random_string.pwd.result
  network_interface_ids = [
    azurerm_network_interface.win.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }
}
