# Separate Plan and Apply stages

## About this template

This template includes a multi-stage pipeline allowing to manually review and approve infrastructure
changes before they are deployed.

![pipeline jobs](/docs/images/terraform_starter/pipeline_jobs.png)

The Terraform definition only deploys a resource group and two empty SQL Server instances
(to illustrate two different approaches to managing secrets, in this case the SQL Server
password).
You can extend the definition with your custom infrastructure, such as Web Apps.

The project can be used in local development without a remote Terraform state backend.
This allows quickly iterating while developing the Terraform configuration, and 
good security practices.

When the project is run in Azure DevOps, however, the pipeline adds the
`infrastructure/terraform_backend/backend.tf` to the `infrastructure/terraform` 
directory to enable the Azure Storage shared backend for additional resiliency.
See the Terraform documentation to understand [why a state store is needed](https://www.terraform.io/docs/state/purpose.html).

## Walkthrough

### Using the template

To use the template, follow the section
[How to use the templates](/README.md#how-to-use-the-templates)
in the main README file.

### Manual approvals

As of December 2019, there is no support for stage gates in Azure DevOps multi-stage pipelines, but
*deployment environments* provide a basic mechanism for stage approvals.

Create an environment with no resources. Name it `Staging`.

![create environment](/docs/images/terraform_starter/create_environment.png)

Define environment approvals. If you want to allow anyone out of a group a people to be able to individually approve, add a group.

![create environment_approval1](/docs/images/terraform_starter/create_environment_approval1.png)

![create environment approval2](/docs/images/terraform_starter/create_environment_approval2.png)

![create environment approval3](/docs/images/terraform_starter/create_environment_approval3.png)

![environment approval](/docs/images/terraform_starter/environment_approval.png)

Repeat those steps for an environment named `QA`.

Under Library, create a Variable Group named `terraform-secrets`. Create a secret
named `SQL_PASSWORD` and give it a unique value (e.g. `Strong_Passw0rd!`). Make
the variable secret using the padlock icon.

![environment approval](/docs/images/terraform_starter/variable_group.png)

### Running the pipeline

As you run the pipeline, after running `terraform plan`, the next stage will be waiting for your approval.

![pipeline stage waiting](/docs/images/terraform_starter/pipeline_stage_waiting.png)

Review the detailed plan to ensure no critical resources or data will be lost.

![terraform plan output](/docs/images/terraform_starter/terraform_plan_output.png)

You can also review the plan and terraform configuration files by navigating to Pipeline Artifacts (rightmost column in the table below).

![pipeline artifacts](/docs/images/terraform_starter/pipeline_artifacts.png)

![pipeline artifacts detail](/docs/images/terraform_starter/pipeline_artifacts_detail.png)

Approve or reject the deployment.

![stage approval waiting](/docs/images/terraform_starter/stage_approval_waiting.png)

The pipeline will proceed to `terraform apply`.

At this stage you will have a new resource group deployed named `rg-starterterraform-stage-main`. 

The pipeline will then proceed in the same manner for the `QA` environment.

![pipeline completed](/docs/images/terraform_starter/pipeline_completed.png)

If any changes have been performed on the infrastructure between the Plan and Apply stages, the pipeline will fail.
You can rerun the Plan stage directly in the pipeline view to produce an updated plan.

![plan changed](/docs/images/terraform_starter/plan_changed.png)

## Next steps

* It's not currently possible to skip approval and deployment if there are no
  changes in the Terraform plan, because of limitations in multi-stage
  pipelines (stages cannot be conditioned on the outputs of previous stages).
  You could cancel the pipeline (through the REST API) in that case, but that
  would prevent extending the pipeline to include activities beyond Terraform.
* The next template, [301-deploy-agent-vms](../301-deploy-agent-vms) demonstrates
  how you can use Terraform to manage infrastructure used for the build itself,
  such as build agent VMs.
