
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ai-data-studio-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ai-data-studio-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "ai-data-studio-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "ai-data-studio-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "confidential_vm" {
  name                = "ai-data-studio-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DC2s_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  admin_password = "P@ssword1234!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true
}

resource "azurerm_key_vault" "kv" {
  name                        = "aiDataStudioKV"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = "00000000-0000-0000-0000-000000000000"
  sku_name                    = "standard"
  soft_delete_enabled         = true
  purge_protection_enabled    = true
}

resource "azurerm_monitor_diagnostic_setting" "monitor" {
  name               = "ai-data-studio-monitor"
  target_resource_id = azurerm_linux_virtual_machine.confidential_vm.id
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ai-data-studio-rg/providers/Microsoft.OperationalInsights/workspaces/aiDataStudioWorkspace"

  log {
    category = "AuditLogs"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
