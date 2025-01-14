terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "West US 2"
}

variable "vm_names" {
  default = ["master", "node1", "node2", "sonar", "nexus","jenkins"]
}

# Resource Group
resource "azurerm_resource_group" "dev" {
  name     = "dev"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "dev_vnet" {
  name                = "dev-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "dev_subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "dev_nsg" {
  name                = "dev-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name

  security_rule {
    name                       = "allow-smtp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "25"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-custom-tcp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000-10000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP Addresses
resource "azurerm_public_ip" "dev_public_ip" {
  count               = 6
  name                = "dev-public-ip-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interfaces
resource "azurerm_network_interface" "dev_nic" {
  count               = 6
  name                = "dev-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_public_ip[count.index].id
  }
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "dev_nic_assoc" {
  count                     = 6
  network_interface_id      = azurerm_network_interface.dev_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.dev_nsg.id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "dev_vm" {
  count               = 6
  name                = "dev-${var.vm_names[count.index]}"
  resource_group_name = azurerm_resource_group.dev.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_password      = "CAPassword123!"
  network_interface_ids = [
    azurerm_network_interface.dev_nic[count.index].id,
  ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# Outputs
output "vm_public_ips" {
  description = "Public IP addresses of the virtual machines"
  value       = { for idx, ip in azurerm_public_ip.dev_public_ip : var.vm_names[idx] => ip.ip_address }
}
