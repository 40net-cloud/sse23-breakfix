terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    aws = {
      source = "hashicorp/aws"
    }
/*    fortiflexvm = {
      source = "fortinetdev/fortiflexvm"
    }*/
    random = {
      source = "hashicorp/random"
    }    
  }
  cloud {
    organization = "sse-workshops23"

    workspaces {
      tags = ["sse23"]
    }
  }
}

resource "random_string" "pwd" {
    length = 12
    min_upper = 1
    min_lower = 1
    min_numeric = 1
}