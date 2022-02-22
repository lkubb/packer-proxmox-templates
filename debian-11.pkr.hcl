source "proxmox-iso" "debian11" {
  boot_command            = [
      "<esc><wait>",
      "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]
  boot_wait               = "10s"
  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_pool
  cores                   = var.cpu_cores
  cpu_type                = var.cpu_type
  disks {
    cache_mode        = var.disk_cache_mode
    disk_size         = var.disk_size
    format            = var.disk_format
    io_thread         = var.disk_io_thread
    storage_pool      = var.disk_pool
    storage_pool_type = var.disk_pool_type
    type              = var.disk_type
  }
  http_directory      = "./seed"
  insecure_skip_tls_verify = var.pm_skip_tls_verify
  iso_checksum        = var.iso_checksum
  iso_file            = var.iso_file
  iso_storage_pool    = var.iso_storage_pool
  iso_url             = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${var.debian_version}-amd64-netinst.iso"
  memory              = var.memory
  network_adapters {
    bridge   = var.nic_bridge
    firewall = var.nic_firewall
    model    = var.nic_model
    packet_queues = var.nic_queues
    vlan_tag = var.nic_vlan
  }
  node                 = var.pm_node
  os                   = "l26"
  password             = var.pm_api_password
  proxmox_url          = "https://${var.pm_host}/api2/json"
  scsi_controller      = var.scsi_controller
  sockets              = "1"
  ssh_password         = "packer"
  ssh_timeout          = var.ssh_timeout
  ssh_username         = "root"
  template_description = "Debian ${var.debian_version} template. Built on {{ isotime \"2006-01-02T15:04:05Z\" }}"
  template_name        = "packer-debian-${var.debian_version}-amd64"
  token                = var.pm_api_key
  unmount_iso          = true
  username             = var.pm_api_username
  vm_id                = var.vm_id
  vm_name              = "packer-debian-${var.debian_version}-amd64"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.proxmox-iso.debian11"]

  provisioner "shell" {
    inline = [
      "apt-get -y update && apt-get -y dist-upgrade",
      "apt-get -y autoremove --purge",
      "apt-get -y clean",
      "cloud-init clean",
    ]
  }
}
