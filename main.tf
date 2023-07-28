resource "azurerm_resource_group" "example_rg" {
  name     = "${var.prefix}-rg-${var.suffix}"
  location = var.location
}
