# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.file.preseed",
    "source.proxmox-iso.debian11",
  ]

  provisioner "shell" {
    environment_vars = [
      "DEFAULT_USERNAME=${var.default_username}",
      "SSH_KEY=${var.ssh_key}",
      "DISK_NAME=${local.diskname}",
      "BACKPORTS=%{ if var.backports }yes%{ else }no%{ endif }"
    ]
    scripts = [
      "scripts/05-grub.sh",
      "scripts/10-sysconfig.sh",
      "scripts/30-upgrade.sh",
      "scripts/50-cloud-init.sh",
      "scripts/99-clean.sh",
    ]
  }

  # disable root login (cloud-init seems not to work somehow)
  provisioner "shell" {
    inline = [
      "passwd -l root",
      "sed -e 's/PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config",
    ]
  }
}
