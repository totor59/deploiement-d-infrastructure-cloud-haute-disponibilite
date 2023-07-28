packer {
  required_plugins {
    azure = {
      version = ">= 0.2.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

# Configuration de la source Azure ARM pour l'image Apache
source "azure-arm" "apache" {
  azure_tags = {
    task = "Image deployment"
  }
  image_offer                       = "UbuntuServer"                           
  image_publisher                   = "Canonical"                              
  image_sku                         = "18.04-LTS"                              
  managed_image_name                = "kav-image"       
  managed_image_resource_group_name = "kav-rg-001"     
  os_type                           = "Linux"                                  
  subscription_id                   = "ec907711-acd7-4191-9983-9577afbe3ce1"   
  use_azure_cli_auth                = true                                     
  location                          = "northeurope"                            
  vm_size                           = "Standard_B1ls"                          
}

build {
  sources = ["source.azure-arm.apache"]                          

  # Provisionnement Shell
  provisioner "shell" {
    inline = [
      "sudo apt-get update",                                     
      "sudo apt-get install -y apache2",                         
      "sudo systemctl enable apache2",                           
      "sudo systemctl start apache2",                            
      "echo 'Hello from the custom web server!' | sudo tee /var/www/html/index.html"   
    ]
  }
}
