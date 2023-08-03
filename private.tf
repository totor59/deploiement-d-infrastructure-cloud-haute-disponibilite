# VM Servers logic
resource "azurerm_virtual_machine" "logic_server" {
  count                 = 3
  name                  = "${var.prefix}-logic-server-${count.index + 1}"
  location              = azurerm_virtual_network.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.logic_server[count.index].id]
  vm_size               = "Standard_B1s"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-logic-osdisk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-logic-${count.index + 1}"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234" # Change this to your desired password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Network Interfaces for VM Servers logic
resource "azurerm_network_interface" "logic_server" {
  count               = 3
  name                = "${var.prefix}-logic-nic-${count.index + 1}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-logic-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "private" {
  name                = "${var.prefix}-private-lb-${var.suffix}"
  location            = azurerm_virtual_network.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "${var.prefix}-private-frontend-ip-${var.suffix}"
    subnet_id            = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "private_backend_pool" {
  name            = "${var.prefix}-private-backend-pool-${var.suffix}"
  loadbalancer_id = azurerm_lb.private.id
}

resource "azurerm_lb_rule" "private" {
  name                           = "${var.prefix}-private-lb-rule-${var.suffix}"
  loadbalancer_id                = azurerm_lb.private.id
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.private_backend_pool.id]
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-private-frontend-ip-${var.suffix}"
}

resource "azurerm_network_interface_backend_address_pool_association" "private" {
  count = 3  # Nombre de VMs serveurs logic
  
  network_interface_id    = azurerm_network_interface.logic_server[count.index].id
  ip_configuration_name   = "${var.prefix}-logic-ipconfig-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.private_backend_pool.id
}



