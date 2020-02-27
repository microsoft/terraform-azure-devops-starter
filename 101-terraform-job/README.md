# Separate Plan and Apply stages

## About this template

This template includes a multi-stage pipeline that deploys 
an environment from Terraform configuration, and run
a subsequent job configured from Terraform outputs.

![pipeline jobs](/docs/images/terraform_starter/101-terraform-job.png)

The Terraform definition only deploys an empty resource group.
You can extend the definition with your custom infrastructure, such as Web Apps.

## Walkthrough

### Using the template

To use the template, follow the section
[How to use the templates](/README.md#how-to-use-the-templates)
in the main README file.

## Next steps

* The next template, [201-plan-apply-stages](../201-plan-apply-stages) demonstrates
  how to manually review and approve changes before they are applied on an environment.
  It also shows you can structure your project to develop and test locally without an Azure
  backend.
