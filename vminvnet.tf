terraform{
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.31.1"
        }
    }
}

provider "azurerm" {
    features {}
}
data "azurerm_resource_group" "test" {
  name = "myResourceGroup"
  /* location = "Central US" */

}
data "azurerm_virtual_network" "test" {
name= "ARMtest"
resource_group_name = "myResourceGroup"
}
data "azurerm_subnet" "test" {
  name                 = "Subnet1"
  virtual_network_name = "ARMtest"
  resource_group_name  = "myResourceGroup"
}

resource "azurerm_network_interface" "test" {
  name                = "testnic"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = data.azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}
  
resource "azurerm_linux_virtual_machine" "vmtest" {
    name                  = "deployvm"
    location              = data.azurerm_resource_group.test.location
    resource_group_name   = data.azurerm_resource_group.test.name
	network_interface_ids = [azurerm_network_interface.test.id]
	size				  =	"Standard_DS1_v2"
    admin_username      = "adminuser"
    admin_password = "Password1234!"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}