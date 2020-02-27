output "agent_vm_ids" {
  value = azurerm_virtual_machine.devops.*.id
}
