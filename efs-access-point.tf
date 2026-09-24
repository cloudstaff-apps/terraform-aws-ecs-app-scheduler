resource "aws_efs_access_point" "default" {
  for_each       = var.efs_mapping
  file_system_id = each.key

  root_directory {
    # Defaults to /<name> so each service is isolated. Override
    # efs_access_point_path to deliberately share a directory between services.
    path = coalesce(var.efs_access_point_path, "/${var.name}")

    creation_info {
      owner_uid   = var.efs_access_point_uid
      owner_gid   = var.efs_access_point_gid
      permissions = var.efs_access_point_permissions
    }
  }
}
