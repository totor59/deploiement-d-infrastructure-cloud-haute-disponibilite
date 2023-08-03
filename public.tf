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
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_backend_pool.id]
}

# VM Servers Web
resource "azurerm_virtual_machine" "web_server" {
  count                 = 3
  name                  = "${var.prefix}-web-server-${count.index + 1}"
  location              = azurerm_virtual_network.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.web_server[count.index].id]
  vm_size               = "Standard_B1s"

  # Storage image configuration
  storage_image_reference {
    id= "/subscriptions/ec907711-acd7-4191-9983-9577afbe3ce1/resourceGroups/kav-rg-001/providers/Microsoft.Compute/images/kav-image"
  }

  storage_os_disk {
    name              = "${var.prefix}-web-osdisk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-web-${count.index + 1}"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234" # Change this to your desired password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Network Interfaces for VM Servers Web
resource "azurerm_network_interface" "web_server" {
  count               = 3
  name                = "${var.prefix}-web-nic-${count.index + 1}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-web-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Adding backend pool to the Load Balancer
resource "azurerm_lb_backend_address_pool" "web_backend_pool" {
  name            = "${var.prefix}-web-backend-pool-${var.suffix}"
  loadbalancer_id = azurerm_lb.public.id
}


resource "azurerm_network_interface_backend_address_pool_association" "public" {
  count = 3  # Nombre de VMs serveurs web
  
  network_interface_id    = azurerm_network_interface.web_server[count.index].id
  ip_configuration_name   = "${var.prefix}-web-ipconfig-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_backend_pool.id
}


