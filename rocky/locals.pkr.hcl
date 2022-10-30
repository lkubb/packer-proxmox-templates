locals {
  disk_type_name_mapping = {
    scsi   = "sda"
    sata   = "sda"
    virtio = "vda"
    ide    = "hda"
  }
  diskname      = local.disk_type_name_mapping[var.disk_type]
  iso_checksum  = coalesce(var.iso_checksum, "file:https://download.rockylinux.org/pub/rocky/${var.rocky_version}/isos/x86_64/Rocky-x86_64-minimal.iso.CHECKSUM")
  root_password = coalesce(var.root_password, uuidv4())
}
