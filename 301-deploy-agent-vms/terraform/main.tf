# Azure DevOps agent VMs

module "devops-agent" {
  source = "./devops-agent"
  appname = var.appname
  environment = var.environment
  location = var.location
  az_devops_url = var.az_devops_url
  az_devops_pat = var.az_devops_pat
  az_devops_agent_pool = var.az_devops_agent_pool
  az_devops_agents_per_vm = var.az_devops_agents_per_vm
  az_devops_agent_sshkeys = var.az_devops_agent_sshkeys
  az_devops_agent_vm_size = var.az_devops_agent_vm_size
  az_devops_agent_vm_count = var.az_devops_agent_vm_count
  az_devops_agent_vm_shutdown_time = var.az_devops_agent_vm_shutdown_time
}

