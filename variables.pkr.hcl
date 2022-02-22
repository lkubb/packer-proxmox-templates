# -- Proxmox variables -- #

variable "pm_host" {
  type        = string
  description = "Proxmox API host domain or IP address. Needs to be accessible with https."
}

variable "pm_api_username" {
  type        = string
  description = "Proxmox API username. When using API key, the format would be e.g. 'packer@pve!packer'."
}

variable "pm_api_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Proxmox password for the API user. Either this or pm_api_key is required."
}

variable "pm_api_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "Proxmox API key for the API user. Either this or pm_api_password is required."
}

variable "pm_node" {
  type        = string
  description = "The target node the template will be built on."
}

variable "pm_skip_tls_verify" {
  type        = bool
  default     = false
  description = "Whether to skip validating the API host TLS certificate."
}

# -- General variables -- #

variable "ssh_timeout" {
  type        = string
  default     = "5m"
  description = "How long to wait for an SSH connection before cancelling (without QEMU guest agent, this is how long the build can take)."
}

variable "debian_version" {
  type        = string
  default     = "11.2.0"
  description = "Latest version of the Debian CD netinstaller ISO. Unnecessary when specifying iso_file and iso_checksum."
}

variable "iso_checksum" {
  type        = string
  default     = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
  description = "The checksum for iso_file when it is specified. Otherwise, leave the default and make sure the debian version is correct."
}

variable "iso_file" {
  type        = string
  default     = null
  description = "By default, this fetches the latest installer online. If you have a local ISO, specify it here like: 'local:iso/debian-11.2.0-amd64-netinst.iso'. Specify iso_checksum as well."
}

variable "iso_storage_pool" {
  type        = string
  default     = "local"
  description = "When not specifying a local ISO, it will be downloaded from official sources. The target storage needs to be specified here. Packer user needs 'Datastore.AllocateTemplate' privileges."
}

# -- Template variables -- #

variable "cloud_init" {
  type        = bool
  default     = true
  description = "Whether to attach a cloud-init CDROM drive to the built template."
}

variable "cloud_init_pool" {
  type        = string
  default     = null
  description = "The storage pool for the cloud-init CDROM. Should default to the storage pool of the boot device, but seems flaky if unspecified."
}

variable "vm_id" {
  type        = number
  default     = 1000
  description = "The VM ID used for the build VM and the built template."
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores for the VM."
}

variable "cpu_type" {
  type        = string
  default     = "kvm64"
  description = "CPU type to emulate. Best performance: 'host'."
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Megabytes of memory to associate with the VM."
}

variable "bios" {
  type        = string
  default     = "seabios"
  description = "Choose the machine BIOS: 'ovmf', 'seabios'."
}

variable "machine" {
  type        = string
  default     = "i440fx"
  description = "Choose the machine type: 'i440fx', 'q35'."
}

variable "scsi_controller" {
  type        = string
  default     = "virtio-scsi-single"
  description = "The SCSI controller model to emulate: lsi, lsi53c810, virtio-scsi-pci, virtio-scsi-single, megasas, pvscsi."
}

# -- Template disk variables -- #

variable "disk_pool" {
  type        = string
  default     = "local-lvm"
  description = "The storage pool for the default disk."
}

variable "disk_pool_type" {
  type        = string
  default     = "lvm-thin"
  description = "The storage pool type for the default disk."
}

variable "disk_size" {
  type        = string
  default     = "5G"
  description = "The disk size of the default disk."
}

variable "disk_cache_mode" {
  type        = string
  default     = "none"
  description = "How to cache operations to the default disk. Can be 'none', 'writethrough', 'writeback', 'unsafe' or 'directsync'."
}

variable "disk_format" {
  type        = string
  default     = "raw"
  description = "The format of the default disk: 'raw', 'cow', 'qcow', 'qed', 'qcow2', 'vmdk', 'cloop'."
}

variable "disk_io_thread" {
  type        = bool
  default     = false
  description = "Create one I/O thread per storage controller, rather than a single thread for all I/O. Requires virtio-scsi-single controller and a scsi or virtio disk."
}

variable "disk_type" {
  type        = string
  default     = "virtio"
  description = "The type of the default disk: 'scsi', 'sata', 'virtio', 'ide'."
}

# -- Template NIC variables -- #

variable "nic_bridge" {
  type        = string
  default     = "vmbr0"
  description = "The bridge the default NIC is attached to."
}

variable "nic_firewall" {
  type        = bool
  default     = false
  description = "Whether to enable the PVE firewall for the default NIC."
}

variable "nic_model" {
  type        = string
  default     = "virtio"
  description = "The model of the default NIC."
}

variable "nic_vlan" {
  type        = string
  default     = null
  description = "The VLAN tag the default bridge uses. Leave empty for untagged."
}

variable "nic_queues" {
  type        = number
  default     = 0
  description = "Number of packet queues to be used on the default NIC. For routers, reverse proxies or busy HTTP servers. Requires virtio network adapter."
}

# variable nics {
#   type = list(object({
#       bridge = string
#       model = string
#       vlan = string
#       queues = number
#     }))
#   default = [
#     {
#       bridge = "vmbr0"
#       model = "virtio"
#       vlan = ""
#       queues = 0
#     }
#   ]
# }
