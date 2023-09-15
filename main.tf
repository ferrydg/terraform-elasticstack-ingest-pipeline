terraform {
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.6.2"
    }
  }
}


locals {
  config     = yamldecode(var.config)
  processors = { for index, processor in local.config.processors : format("%.4d", index) => processor }
}
module "processors" {
  for_each  = local.processors
  source    = "app.terraform.io/Desiderius/ingest-pipeline-processor/elasticstack"
  version   = "1.0.0"
  processor = each.value
}

resource "elasticstack_elasticsearch_ingest_pipeline" "ingest" {
  name = var.name

  processors = values(module.processors)[*].json
}