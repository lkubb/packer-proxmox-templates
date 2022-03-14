locals {
  disk_type_name_mapping = {
    scsi    = "sda"
    sata    = "sda"
    virtio  = "vda"
    ide     = "hda"
  }
  diskname = local.disk_type_name_mapping[var.disk_type]
}
