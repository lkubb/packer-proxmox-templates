# Packer for Proxmox
## Cloud-init Caveats
### Bootcmd and autogrow
- Runtime configuration is drawn from multiple sources. If more than one is available, the one with the highest priority is selected, [no merging is applied](https://github.com/canonical/cloud-init/blob/fca5bb77c251bea6ed7a21e9b9e0b320a01575a9/cloudinit/sources/DataSourceNoCloud.py#L363-L380). There is a fallback to a seed directory commonly found in `/var/lib/cloud/seed/nocloud`.
- I'm not entirely whether an existing `vendor-data` seed will be preserved when a higher priority datasource does not expose one since Proxmox always presents one, even if it has not been configured ([in that case it's empty](https://github.com/proxmox/qemu-server/blob/d8a7e9e881e29c899920657f98a0047d9d63abed/PVE/QemuServer/Cloudinit.pm#L490-L505)).
- Multiple separate source trees exist (relevant here: `user-data`, `vendor-data`, `cfg`). If one root key (eg `bootcmd`) is found in multiple sources, again the one with the highest priority is selected, no merging is applied (`user-data` having the highest). Merging configuration only works inside one tree.

This template is preconfigured to automatically grow the root partition (via `cloud.cfg`, see `seed/cloud-init.sh`). Since `cloud-init` does not support growing LVM partitions atm, it needs to set a `bootcmd`. The combination of both behaviors above results in a tradeoff for this template:

If you want to set `bootcmd` in your user-data, it will overwrite the preconfigured commands and the **volume will not grow automatically**. There is no workaround for this behavior inside the scope of `cloud-init` and this packer template alone since a seed for `user-data` would be disregarded anyway once Proxmox presents its configuration. Fix by including the relevant commands in your userdata.

## Preparation

### PVE User account

You will need a dedicated user account for Packer.
The following commands add one with the required privileges [[Source](https://github.com/hashicorp/packer/issues/8463#issuecomment-726844945)]:

```bash
pveum useradd packer@pve
pveum passwd packer@pve
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor"
pveum aclmod / -user packer@pve -role Packer
```

To upload ISO images, `Datastore.AllocateTemplate` privilege might be needed as well.

### PVE API Key

You can add an API key for this user as well. Suppose the key's label is `packer`, `pm_api_username` will be `packer@pve!packer`.

## Preseed File

To automate the Debian ISO netinstaller setup, you need to provide a `preseed.cfg` file inside `./seed`. See [here](https://preseed.debian.net/debian-preseed/bullseye/amd64-main-full.txt) for all options. An example preseed file with most common options (that should work) is found in [preseed.cfg](preseed.cfg).

Especially take care with `d-i grub-installer/bootdev`, where the default of `/dev/sda` has to be modified to be `/dev/vda` in my case. Your preseed file should also install `qemu-guest-agent` and `cloud-init`.

The following is an overview of the specified values in the example config:

```bash
d-i debian-installer/locale string en_US.UTF-8
d-i debian-installer/language string en
d-i debian-installer/country string US
d-i keyboard-configuration/xkb-keymap select us
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/wireless_wep string
d-i hw-detect/load_firmware boolean false
d-i mirror/country string manual United States
d-i mirror/http/hostname string http.us.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i passwd/make-user boolean false
d-i passwd/root-password password packer
d-i passwd/root-password-again password packer
d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern
d-i clock-setup/ntp boolean true
# the example chooses lvm - this will currently prevent
# cloud-init from automatically resizing the root disk
# this is done with runcmd config (see cloud-init.sh)
# another method would be to use regular method and
# a custom partman-auto/expert_recipe
# to put the root partition last (by default swap is last)
d-i partman-auto/method string lvm
d-i partman-auto-lvm/guided_size string max
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string qemu-guest-agent cloud-init vim
popularity-contest popularity-contest/participate boolean false
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string /dev/vda
d-i finish-install/reboot_in_progress note
d-i preseed/late_command string in-target sed -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
```

## Pkrvars

For all variables, see [variables.pkr.hcl](variables.pkr.hcl). For an example `pkrvars.hcl` file, see [my.pkrvars.example.hcl](my.pkrvars.example.hcl). If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

The variables below are a selection of probably relevant ones.

### Required

Packer requires some variables to be able to connect to Proxmox.

Note: Those are sensitive and should not be checked into version control!

```hcl
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
# ssh key of default admin user
ssh_key = "ssh-dsa ..."
```

### Optional

You can further customize the built template by setting some optional variables. Note that `debian_version` should be checked to be the latest version (in case you don't specify a local iso).

```hcl
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
# The VGA type: cirrus, none, qxl, qxl2, qxl3, qxl4, serial0, serial1, serial2, serial3, std, virtio, vmware
vga_type = "serial0"
# VGA memory in MiB. Note: this is superfluous when using a serial console.
vga_memory = 64
# The default admin username.
default_username = "debian"
```

## Running

### Validation

You can validate your configuration by running:

```bash
packer validate -var-file my.pkrvars.hcl .
```

This should output `The configuration is valid.`.

### Building

After all the configuration, building the template is easily done:

```bash
packer build -var-file my.pkrvars.hcl .
```

Mind that the Packer Proxmox plugin currently does not provide a way to overwrite an existing template, so to regenerate your template with the same ID, you will need to delete it manually before running the above command.

### Manual post-processing

Currently, [there is no way to add a serial port](https://github.com/hashicorp/packer-plugin-proxmox/issues/41) to the template using the Packer Proxmox plugin. In the default configuration, that is necessary since VGA is set to `serial0`. You will need to create this one manually.

## Flow
This is a short overview of the build steps:

1. Downloads ISO if no local one was specified
2. Creates VM as specified
3. Uses preseed.cfg to automate the installation of Debian. Note:

    * adds necessary packages: `qemu-guest-agent`, `cloud-init`, `vim` (!)
    * adds `root` user with password `packer`
    * allows ssh password auth for `root` (temporarily for provisioning)

4. Configures grub (adds `console=ttyS0`, `elevator=none`, no timeout)
5. Adds sysconfig (`vm.swappiness = 1`)
6. Updates & upgrades system, cleans cloud-init and apt cache
7. Sets basic cloud-init config:

    * by default mostly Debian default with some changes (see `scripts/cloud-init.sh`)
    * possibility to change the default admin username
    * ssh key setup for default admin user
    * Proxmox specifics

8. Locks root account
9. Prohibits ssh root login
10. Shuts down VM and converts it to a template

When logging in for the first time, you should set a password for your user (`sudo passwd <username>` is needed) and remove passwordless sudo.

## Todo
- check https://github.com/kwilczynski/packer-templates/blob/899646c9504d5d0e0da2794223a7113d4e13f20c/scripts/common/update.sh
