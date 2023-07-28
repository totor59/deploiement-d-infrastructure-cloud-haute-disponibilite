resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet-${var.suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Définissez les sous-réseaux
resource "azurerm_subnet" "public" {
  name                 = "${var.prefix}-pub-subnet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "${var.prefix}-priv-subnet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}