# Créez un Load Balancer Public
resource "azurerm_lb" "public" {
  name                = "${var.prefix}-pub_lb-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-public_ip-${var.suffix}"
    public_ip_address_id = azurerm_public_ip.public.id
  }
}

resource "azurerm_lb_rule" "public" {
  name                           = "${var.prefix}-lb_rule-${var.suffix}"
  loadbalancer_id                = azurerm_lb.public.id 
  protocol                       = "Tcp"
  backend_port                   = 80
  frontend_port                  = 80
  frontend_ip_configuration_name = "${var.prefix}-public_ip-${var.suffix}"
}

