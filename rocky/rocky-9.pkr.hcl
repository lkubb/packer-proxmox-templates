source "proxmox-iso" "rocky9" {
  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>",
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
  http_directory           = "./seed"
  insecure_skip_tls_verify = var.pm_skip_tls_verify
  iso_checksum             = local.iso_checksum
  iso_file                 = var.iso_file
  iso_storage_pool         = var.iso_storage_pool
  iso_url                  = "https://download.rockylinux.org/pub/rocky/${var.rocky_version}/isos/x86_64/Rocky-x86_64-minimal.iso"
  memory                   = var.memory
  network_adapters {
    bridge        = var.nic_bridge
    firewall      = var.nic_firewall
    model         = var.nic_model
    packet_queues = var.nic_queues
    vlan_tag      = var.nic_vlan
  }
  node                 = var.pm_node
  os                   = "l26"
  password             = var.pm_api_password
  proxmox_url          = "https://${var.pm_host}/api2/json"
  scsi_controller      = var.scsi_controller
  sockets              = "1"
  ssh_password         = local.root_password
  ssh_timeout          = var.ssh_timeout
  ssh_username         = "root"
  template_description = "Rocky Linux ${var.rocky_version} template. Built on {{ isotime \"2006-01-02T15:04:05Z\" }}"
  template_name        = "rocky${ split(".", var.rocky_version)[0] }"
  token                = var.pm_api_key
  unmount_iso          = true
  username             = var.pm_api_username
  vga {
    type   = var.vga_type
    memory = var.vga_memory
  }
  vm_id   = var.vm_id
  vm_name = "packer-rocky-${var.rocky_version}-amd64"
}
