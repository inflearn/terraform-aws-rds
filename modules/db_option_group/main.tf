locals {
  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null

  description = coalesce(var.option_group_description, format("%s option group", var.name))
}

resource "aws_db_option_group" "this" {
  count = var.create ? 1 : 0

  name                     = local.name
  name_prefix              = local.name_prefix
  option_group_description = local.description
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = try(option.value.port, null)
      version                        = try(option.value.version, null)
      db_security_group_memberships  = try(option.value.db_security_group_memberships, null)
      vpc_security_group_memberships = try(option.value.vpc_security_group_memberships, null)

      dynamic "option_settings" {
        for_each = try(option.value.option_settings, [])
        content {
          name  = try(option_settings.value.name, null)
          value = try(option_settings.value.value, null)
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )

  timeouts {
    delete = try(var.timeouts.delete, null)
  }

  lifecycle {
    create_before_destroy = true
  }
}
