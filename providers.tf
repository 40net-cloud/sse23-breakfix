provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "aws" {
  region = var.aws_region
//  access_key = var.aws_key_id
//  secret_key = var.aws_key_secret
}
/*
provider "fortiflexvm" {
  import_options = toset(["config_id=4091"])
}
*/