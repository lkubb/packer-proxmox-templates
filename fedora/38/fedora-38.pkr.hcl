locals {
  bootcmd_syslinux = [
    "<up><tab>",
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter><wait>",
  ]
  bootcmd_grub = [
    "<up>e",
    "<down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
  boot_command = concat(
    [for s in local.bootcmd_syslinux : s if var.iso_bootloader == "syslinux"],
    [for s in local.bootcmd_grub : s if var.iso_bootloader == "grub2"],
  )
  iso_url_map = {
    dvd = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-dvd-x86_64-38-1.6.iso"
    netinstall = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-netinst-x86_64-38-1.6.iso"
  }
  iso_url = var.netinstall ? local.iso_url_map["netinstall"] : local.iso_url_map["dvd"]
  disk_type_name_mapping = {
    scsi   = "sda"
    sata   = "sda"
    virtio = "vda"
    ide    = "hda"
  }
  diskname      = local.disk_type_name_mapping[var.disk_type]
  iso_checksum  = coalesce(var.iso_checksum, "file:https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-38-1.6-x86_64-CHECKSUM")
  root_password = coalesce(var.root_password, uuidv4())
}

source "proxmox-iso" "fedora38" {
  boot_command = local.boot_command
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
  http_directory           = "${path.root}/seed"
  insecure_skip_tls_verify = var.pm_skip_tls_verify
  iso_checksum             = local.iso_checksum
  iso_file                 = var.iso_file
  iso_storage_pool         = var.iso_storage_pool
  iso_url                  = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-netinst-x86_64-38-1.6.iso"
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
  template_description = "Fedora 38 template. Built on {{ isotime \"2006-01-02T15:04:05Z\" }}"
  template_name        = "fedora38"
  token                = var.pm_api_key
  unmount_iso          = true
  username             = var.pm_api_username
  vga {
    type   = var.vga_type
    memory = var.vga_memory
  }
  vm_id   = var.vm_id
  vm_name = "packer-fedora-38-amd64"
}
