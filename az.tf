
/*resource "azurerm_resource_group" "sse" {
    name     = "${var.prefix}-sse"
    location = var.az_region
    tags = var.az_tags
}
*/

/***********   LB   **************/

resource "azurerm_public_ip" "elb" {
    name = "${var.prefix}-pip-elb"
    location = var.az_region
    resource_group_name = var.az_rg_name
    allocation_method = "Static"
    zones = [1,2,3]
    sku = "Standard"
}

resource "azurerm_lb" "elb" {
    name = "${var.prefix}-elb"
    location = var.az_region
    resource_group_name = var.az_rg_name
    sku = "Standard"

    frontend_ip_configuration {
        name = "pip1"
        public_ip_address_id = azurerm_public_ip.elb.id
    }
}

resource "azurerm_lb_backend_address_pool" "elb" {
    loadbalancer_id = azurerm_lb.elb.id
    name = "fgtha"
}

resource "azurerm_lb_probe" "tcp8008" {
    name = "${var.prefix}-probe-tcp8000"
    loadbalancer_id = azurerm_lb.elb.id
    port = 8000
}

resource "azurerm_lb_rule" "elb" {
    for_each = var.az_elb_ports

    loadbalancer_id = azurerm_lb.elb.id
    frontend_ip_configuration_name = "pip1"
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.elb.id]
    name = each.key
    protocol = split(":", each.value)[0]
    frontend_port = split(":", each.value)[1]
    backend_port = split(":", each.value)[1]
    enable_floating_ip = true
    probe_id = azurerm_lb_probe.tcp8008.id
    disable_outbound_snat = true
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt_elb" {
    count = 2

    network_interface_id    = azurerm_network_interface.ext[count.index].id
    ip_configuration_name   = "ipconfig1"
    backend_address_pool_id = azurerm_lb_backend_address_pool.elb.id
}

resource "azurerm_lb_outbound_rule" "fgt_out" {
  name                    = "fgt_out"
  loadbalancer_id         = azurerm_lb.elb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb.id

  frontend_ip_configuration {
    name = "pip1"
  }
}

/********************  ARS  *********************/

resource "azurerm_public_ip" "ars" {
    name = "${var.prefix}-ars-pip"
    location = var.az_region
    resource_group_name = var.az_rg_name
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_subnet" "ars" {
    name = "RouteServerSubnet"
    resource_group_name  = var.az_rg_name
    virtual_network_name = azurerm_virtual_network.fgt.name
    address_prefixes     = ["172.20.0.128/27"]
}

resource "azurerm_route_server" "ars" {
    name = "${var.prefix}-ars"
    resource_group_name = var.az_rg_name
    location = var.az_region
    sku = "Standard"
    subnet_id = azurerm_subnet.ars.id
    public_ip_address_id = azurerm_public_ip.ars.id
}

resource "azurerm_route_server_bgp_connection" "fgts" {
    count = 2

    name = "bgp-fgt${count.index+1}"
    route_server_id = azurerm_route_server.ars.id
    peer_asn = var.fgt_asn_az
    peer_ip = azurerm_network_interface.int[count.index].private_ip_address
}
