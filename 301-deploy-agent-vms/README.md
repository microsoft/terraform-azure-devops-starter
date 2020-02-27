# Deploy hosted agent VMs

## About this template

This template shows how to use Terraform to deploy a pool of agent VMs on which a subsequent job is run.

![agent pool](/docs/images/terraform_starter/301-agent-pool.png)

The Terraform definition does not contain any other resources.
You can extend the definition with your custom infrastructure, such as Web Apps.

## Walkthrough

### Creating an agent pool

In your Azure DevOps project settings, [create an Agent pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues).
Name the pool `starterpool` (if you want to use a different name, change the value in [azure-pipelines.yml](azure-pipelines.yml)).

starterpool

### Creating a PAT token

In Azure DevOps, [create a PAT token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page).
Click on *Show all scopes* and grant the token *Read and Manage* permissions on *Agent Pools*.

![PAT token](/docs/images/terraform_starter/301-pat-token.png)

Under Library, create a Variable Group named `terraform-secrets`. Create a secret
named `AGENT_POOL_MANAGE_PAT_TOKEN` and paste the token value
Make the variable secret using the padlock icon.

### Using the template

To use the template, follow the section
[How to use the templates](/README.md#how-to-use-the-templates)
in the main README file.

### Automatic shutdown of agents

The pipeline configures the agent VMs to automatically shutdown daily at 23:00 UTC.
To use a different schedule, change `TF_VAR_az_devops_agent_vm_shutdown_time`
in [azure-pipelines.yml](azure-pipelines.yml),
or remove that line completely to disable automatic shutdown.

The pipeline contains a task to start up the agent VMs again before running the agent job.
