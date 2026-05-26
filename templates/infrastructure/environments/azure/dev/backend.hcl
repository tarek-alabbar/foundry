# Azure blob backend for dev environment Terraform state
# These values are output by `task infra:bootstrap`
resource_group_name  = "rg-<<APP_NAME>>-tfstate"
storage_account_name = "<<APP_NAME_CLEAN>>tfstate"
container_name       = "tfstate"
key                  = "<<APP_NAME>>/dev/terraform.tfstate"
