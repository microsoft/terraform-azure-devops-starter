output "pool_name" {
  value = var.az_devops_agent_pool
}

output "agent_vm_ids" {
  value = module.devops-agent.agent_vm_ids
}
