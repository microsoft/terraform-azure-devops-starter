variable "appname" {
  type = string
  description = "Application name. Use only lowercase letters and numbers"
  default = "starterterraform"
}

variable "environment" {
  type    = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default = "dev"
}

variable "location" {
  type    = string
  description = "Azure region where to create resources."
  default = "North Europe"
}

variable "department" {
  type    = string
  description = "A sample variable passed from the build pipeline and used to tag resources."
  default = "Engineering"
}

variable "az_devops_url" {
  type = string
  description = "Specify the Azure DevOps url e.g. https://dev.azure.com/myorg"
}

variable "az_devops_pat" {
  type = string
  description = "Provide a Personal Access Token (PAT) for Azure DevOps. Create it at https://dev.azure.com/[Organization]/_usersSettings/tokens with permission Agent Pools > Read & manage"
}

variable "az_devops_agent_pool" {
  type = string
  description = "Specify the name of the agent pool - must exist before. Create it at https://dev.azure.com/[Organization]/_settings/agentpools"
  default = "pool001"
}

variable "az_devops_agent_sshkeys" {
  type        = list(string)
  description = "Optionally provide ssh public key(s) to logon to the VM"
  default     = []
}

variable "az_devops_agent_vm_size" {
  type    = string
  description = "Specify the size of the VM"
  default = "Standard_D2s_v3"
}

variable "az_devops_agent_vm_count" {
  type    = number
  description = "Number of Azure DevOps agent VMs"
  default = 2
}

variable "az_devops_agents_per_vm" {
  type = number
  description = "Number of Azure DevOps agents spawned per VM. Agents will be named with a random prefix."
  default = 4
}

variable "az_devops_agent_vm_shutdown_time" {
  type    = string
  description = "UTC Time at which to shutdown the agent VMs daily, for example '2000' for 8 PM. If null, no shutdown will configured."
  default = null
}
