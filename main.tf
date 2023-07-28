resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg-${var.suffix}"
  location = var.location
}
