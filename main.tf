# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}
# Deploy de Recursos
# Deploy Resource Group
resource "azurerm_resource_group" "RG" {
  name     = "RG-Olimpiadas"
  location = "westus2"
}

# Deploy Storage Account
resource "azurerm_storage_account" "sto" {
  name                     = "stotftecrsprd0050"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Deploy Azure Files
resource "azurerm_storage_share" "share" {
  name                 = "files-prd"
  storage_account_name = azurerm_storage_account.sto.name
  quota                = 10

}

# Deploy VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-01"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = ["10.50.0.0/16"]
}

# Deploy Subnet
resource "azurerm_subnet" "sub1" {
  name                 = "SUB-LAN01"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.50.0.0/24"]
}

# Deploy NSG
resource "azurerm_network_security_group" "nsg1" {
  name                = "NSG-WIN"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.0.0/24"
  }
}

# Associar NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg1" {
  subnet_id                 = azurerm_subnet.sub1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}


# Deploy Public IP
resource "azurerm_public_ip" "PIP" {
  name                = "PIP-VM-SRV01"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Dynamic"
}

# Deploy NIC
resource "azurerm_network_interface" "vnic" {
  name                = "nic-vm-srv01"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PIP.id
  }
}

# Deploy VM
resource "azurerm_windows_virtual_machine" "vm" {
  name                            = "VM-SRV01"
  resource_group_name             = azurerm_resource_group.RG.name
  location                        = azurerm_resource_group.RG.location
  size                            = "Standard_B2S"
  admin_username                  = "admintftec"
  admin_password                  = "Olimpiadas@12345"
  network_interface_ids = [
    azurerm_network_interface.vnic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}








# Deploy Storage Account
resource "azurerm_storage_account" "sto1" {
  name                     = "stotftecrshml0050"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Deploy Azure Files
resource "azurerm_storage_share" "share1" {
  name                 = "files-hml"
  storage_account_name = azurerm_storage_account.sto1.name
  quota                = 10

}

# Deploy VNET
resource "azurerm_virtual_network" "vnet2" {
  name                = "VNET-02"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = ["172.16.0.0/16"]
}

# Deploy Subnet
resource "azurerm_subnet" "sub2" {
  name                 = "SUB-LAN02"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["172.16.0.0/24"]
}

# Deploy NSG
resource "azurerm_network_security_group" "nsg2" {
  name                = "NSG-LNX"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "172.16.0.0/24"
  }
}

# Associar NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg2" {
  subnet_id                 = azurerm_subnet.sub2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

# Deploy Public IP
resource "azurerm_public_ip" "PIP2" {
  name                = "PIP-VM-SRV02"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Dynamic"
}

# Deploy NIC
resource "azurerm_network_interface" "vnic2" {
  name                = "nic-vm-srv02"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PIP2.id
  }
}

# Deploy VM
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "VM-SRV02"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_B2S"
    network_interface_ids = [
    azurerm_network_interface.vnic2.id,
  ]
 computer_name  = "VM-SRV02"
    admin_username = "admintftec"
    admin_password = "Olimpiadas@12345"
    disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
  