resource "azurerm_resource_group" "devops" {
  name   = "rg-${var.appname}-${var.environment}-devops"
  location = var.location
}

# Create virtual network

resource "azurerm_virtual_network" "devops" {
  name                = "vnet-${var.appname}-devops-${var.environment}"
  address_space       = ["10.100.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.devops.name
}

resource "azurerm_subnet" "devops" {
  name                 = "agents-subnet"
  resource_group_name  = azurerm_resource_group.devops.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefix       = "10.100.1.0/24"
}

resource "azurerm_storage_account" "devops" {
  name                     = "stado${var.appname}${var.environment}"
  resource_group_name      = azurerm_resource_group.devops.name
  location                 = azurerm_resource_group.devops.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "devops" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.devops.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "devops" {
  name                   = "devops_agent_init-${md5(file("${path.module}/devops_agent_init.sh"))}.sh"
  storage_account_name   = azurerm_storage_account.devops.name
  storage_container_name = azurerm_storage_container.devops.name
  type                   = "Block"
  source                 = "${path.module}/devops_agent_init.sh"
}

data "azurerm_storage_account_blob_container_sas" "devops_agent_init" {
  connection_string = azurerm_storage_account.devops.primary_connection_string
  container_name    = azurerm_storage_container.devops.name
  https_only        = true

  start  = "2000-01-01"
  expiry = "2099-01-01"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}


# Create public IPs
resource "azurerm_public_ip" "devops" {
  name                = "pip-${var.appname}-devops-${var.environment}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.devops.name
  allocation_method   = "Dynamic"
  count               = var.az_devops_agent_vm_count
}

# Create network interface
resource "azurerm_network_interface" "devops" {
  name                      = "nic-${var.appname}-devops-${var.environment}-${format("%03d", count.index + 1)}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.devops.name

  ip_configuration {
    name                          = "AzureDevOpsNicConfiguration"
    subnet_id                     = azurerm_subnet.devops.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.devops[count.index].id
  }

  count                     = var.az_devops_agent_vm_count
}

# Create virtual machine

resource "random_password" "agent_vms" {
  length = 24
  special = true
  override_special = "!@#$%&*()-_=+[]:?"
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_virtual_machine" "devops" {
  name                  = "vm${var.appname}devops${var.environment}-${format("%03d", count.index + 1)}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.devops.name
  network_interface_ids = [azurerm_network_interface.devops[count.index].id]
  vm_size               = var.az_devops_agent_vm_size

  storage_os_disk {
    name              = "osdisk${var.appname}devops${var.environment}${format("%03d", count.index + 1)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "AzureDevOps"
    admin_username = "azuredevopsuser"
    admin_password = random_password.agent_vms.result
  }

  os_profile_linux_config {
    disable_password_authentication = false

    dynamic "ssh_keys" {
      for_each = var.az_devops_agent_sshkeys
      content {
        key_data = each.key
        path = "/home/azuredevopsuser/.ssh/authorized_keys"
      }
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.devops.primary_blob_endpoint
  }

  count = var.az_devops_agent_vm_count
}

resource "azurerm_virtual_machine_extension" "devops" {
  name                 = format("install_azure_devops_agent-%03d", count.index + 1)
  virtual_machine_id   = azurerm_virtual_machine.devops[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  #timestamp: use this field only to trigger a re-run of the script by changing value of this field.
  #           Any integer value is acceptable; it must only be different than the previous value.
  settings = jsonencode({
    "timestamp" : 1
  })
  protected_settings = jsonencode({
  "fileUris": ["${azurerm_storage_blob.devops.url}${data.azurerm_storage_account_blob_container_sas.devops_agent_init.sas}"],
  "commandToExecute": "bash ${azurerm_storage_blob.devops.name} '${var.az_devops_url}' '${var.az_devops_pat}' '${var.az_devops_agent_pool}' '${var.az_devops_agents_per_vm}'"
  })
  count = var.az_devops_agent_vm_count
}

resource "azurerm_template_deployment" "devops_shutdown" {
  name = format("shutdown-vm-%03d", count.index + 1)
  resource_group_name = azurerm_resource_group.devops.name

  template_body = file("${path.module}/shutdown_schedule_arm_template.json")

  parameters = {
    name = "shutdown-computevm-${azurerm_virtual_machine.devops[count.index].name}"
    shutdown_enabled = var.az_devops_agent_vm_shutdown_time != null ? "Enabled" : "Disabled"
    shutdown_time = coalesce(var.az_devops_agent_vm_shutdown_time, "0000")
    vm_id = azurerm_virtual_machine.devops[count.index].id
  }

  depends_on = [
    azurerm_virtual_machine.devops
  ]

  deployment_mode = "Incremental"

  count = var.az_devops_agent_vm_count
}

