# -- REQUIRED -- #

# Proxmox API host domain or IP address. Needs to be accessible with https.
pm_host = "pve1.lan:8006"
# Proxmox API username. When using API key, the format would be e.g. 'packer@pve!packer'.
pm_api_username = "packer@pve!packer"
# Proxmox API key. Either this or pm_api_password is required.
pm_api_key = "0a1b2c3d-4e5f-678a-9b0c1-d2e3f4a5b6c7"
# Proxmox API password. Either this or pm_api_key is required.
pm_api_password = null
# The target node the template will be built on.
pm_node = "pve1"

# -- OPTIONAL -- #

# Whether to skip validating the API host TLS certificate.
pm_skip_tls_verify = true
# If you have a local ISO, specify it here.
# iso_file = "local:iso/debian-11.2.0-amd64-netinst.iso"
# If you have a local ISO, specify its checksum here.
# iso_checksum = "c685b85cf9f248633ba3cd2b9f9e781fa03225587e0c332aef2063f6877a1f0622f56d44cf0690087b0ca36883147ecb5593e3da6f965968402cdbdf12f6dd74"
# If you don't have a local ISO, make sure the debian version
# specified below is the current netinstaller one.
debian_version = "11.2.0"
# Whether to attach a cloud-init CDROM drive to the built template.
cloud_init = true
# The storage pool for the cloud-init CDROM.
cloud_init_pool = "local-lvm"
# The VM ID used for the build VM and the built template.
vm_id = 1000
# Number of CPU cores for the VM.
cpu_cores = 2
# CPU type to emulate. Best performance: 'host'.
cpu_type = "host"
# Megabytes of memory to associate with the VM.
memory = "2048"
# The storage pool for the default disk.
disk_pool = "local-lvm"
# The storage pool type for the default disk.
disk_pool_type = "lvm-thin"
# The disk size of the default disk.
disk_size = "5G"
# The type of the default disk: 'scsi', 'sata', 'virtio', 'ide'.
disk_type = "virtio"
# The bridge the default NIC is attached to.
nic_bridge = "vmbr0"
# Whether to enable the PVE firewall for the default NIC.
nic_firewall = false
# The model of the default NIC.
nic_model = "virtio"
