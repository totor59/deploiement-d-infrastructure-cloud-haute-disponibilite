resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet-${var.suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Définissez les sous-réseaux
resource "azurerm_subnet" "public" {
  name                 = "${var.prefix}-pub_subnet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "${var.prefix}-priv_subnet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}

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

# Créez une adresse IP publique pour le Load Balancer
resource "azurerm_public_ip" "public" {
  name                = "${var.prefix}-public_ip-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}