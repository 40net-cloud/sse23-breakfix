resource "azurerm_virtual_network" "fgt" {
    name = "${var.prefix}-sse-fgt"
    location = var.az_region
    resource_group_name = var.az_rg_name
    address_space = ["172.20.0.0/16"]
}

resource "azurerm_subnet" "ext" {
    name                 = "${var.prefix}-sb-ext"
    resource_group_name  = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.fgt.name
    address_prefixes     = ["172.20.0.0/28"]
}
resource "azurerm_subnet" "int" {
    name                 = "${var.prefix}-sb-int"
    resource_group_name  = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.fgt.name
    address_prefixes     = ["172.20.0.16/28"]
}
resource "azurerm_subnet" "mgmt" {
    name                 = "mgmt"
    resource_group_name  = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.fgt.name
    address_prefixes     = ["172.20.0.64/28"]
}

resource "azurerm_virtual_network" "wrkld" {
    name = "${var.prefix}-sse-wrkld"
    location = var.az_region
    resource_group_name = var.az_rg_name
    address_space = ["10.100.0.0/16"]
}

resource "azurerm_subnet" "wrkld" {
    name = "wrkld"
    resource_group_name  = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.wrkld.name
    address_prefixes     = ["10.100.100.0/24"]    
}

resource "azurerm_virtual_network_peering" "hub_wrkld" {
    name = "${var.prefix}-peer-hub-wrkld"
    resource_group_name = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.fgt.name
    remote_virtual_network_id = azurerm_virtual_network.wrkld.id
    allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "wrkld_hub" {
    name = "${var.prefix}-peer-wrkld-hub"
    resource_group_name = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.wrkld.name
    remote_virtual_network_id = azurerm_virtual_network.fgt.id
    use_remote_gateways = false
    allow_forwarded_traffic = true
    depends_on = [
        azurerm_route_server_bgp_connection.fgts
    ]
}

resource "azurerm_network_security_group" "fgt_mgmt" {
    name = "${var.prefix}-nsg-fgt-mgmt"
    location = var.az_region
    resource_group_name = var.az_rg_name

    security_rule {
        name                    = "allow-admin"
        protocol                = "Tcp"
        source_address_prefix   = "Internet"
        source_port_range       = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges = [
            443,
            22
        ]
        access                  = "Allow"
        priority = 100
        direction = "Inbound"
    }
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
    subnet_id = azurerm_subnet.mgmt.id
    network_security_group_id = azurerm_network_security_group.fgt_mgmt.id
}

resource "azurerm_network_security_group" "allow_all" {
    name = "${var.prefix}-nsg-allowall"
    location = var.az_region
    resource_group_name = var.az_rg_name

    security_rule {
        name                    = "allow-all-in"
        protocol                = "*"
        source_address_prefix   = "*"
        source_port_range       = "*"
        destination_address_prefix = "*"
        destination_port_range  = "*"
        access                  = "Allow"
        priority = 100
        direction = "Inbound"
    }
        security_rule {
        name                    = "allow-all-out"
        protocol                = "*"
        source_address_prefix   = "*"
        source_port_range       = "*"
        destination_address_prefix = "*"
        destination_port_range  = "*"
        access                  = "Allow"
        priority = 100
        direction = "Outbound"
    }
}

resource "azurerm_subnet_network_security_group_association" "allowall" {
    subnet_id = azurerm_subnet.ext.id
    network_security_group_id = azurerm_network_security_group.allow_all.id
}