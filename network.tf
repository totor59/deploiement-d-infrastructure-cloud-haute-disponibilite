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
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet" "private" {
  name                 = "${var.prefix}-priv_subnet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Créez une adresse IP publique pour le Load Balancer
resource "azurerm_public_ip" "public" {
  name                = "${var.prefix}-public_ip-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# Créez un NSG pour le VNet
resource "azurerm_network_security_group" "vnet" {
  name                = "${var.prefix}-vnet-nsg-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Créez un NSG pour le sous-réseau public
resource "azurerm_network_security_group" "public" {
  name                = "${var.prefix}-public_subnet-nsg-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Créez un NSG pour le sous-réseau privé
resource "azurerm_network_security_group" "private" {
  name                = "${var.prefix}-priv_subnet-nsg-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Règles de sécurité pour le NSG du VNet
resource "azurerm_network_security_rule" "vnet_inbound" {
  name                        = "${var.prefix}-vnet-inbound-rule-${var.suffix}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.vnet.name
}

resource "azurerm_network_security_rule" "vnet_outbound" {
  name                        = "${var.prefix}-vnet-outbound-rule-${var.suffix}"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.vnet.name
}

# Règles de sécurité pour le NSG du sous-réseau public
resource "azurerm_network_security_rule" "public_inbound" {
  name                        = "${var.prefix}-public-inbound-rule-${var.suffix}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.public.name
}

# Règles de sécurité pour le NSG du sous-réseau privé
resource "azurerm_network_security_rule" "private_inbound" {
  name                        = "${var.prefix}-private-inbound-rule-${var.suffix}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.1.0/24" # Permet le trafic en provenance du sous-réseau public uniquement
  destination_address_prefix  = "10.0.2.0/24"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.private.name
}