bucket         = "<<APP_NAME_CLEAN>>-tfstate"
key            = "<<APP_NAME>>/staging/terraform.tfstate"
region         = "<<REGION>>"
dynamodb_table = "<<APP_NAME_CLEAN>>-tfstate-lock"
encrypt        = true
