build {
  sources = [
    "source.file.kickstart",
    "source.proxmox-iso.fedora38",
  ]

  provisioner "shell" {
    environment_vars = []
    scripts = [
      "${path.root}/../scripts/10-sysconfig.sh",
      "${path.root}/../scripts/30-upgrade.sh",
      # this needs to happen after kernel upgrades to at least
      # apply for the template. after another upgrade, ttyS0 is gone again -.-
      "${path.root}/../scripts/40-grub.sh",
      "${path.root}/../scripts/50-cloud-init.sh",
      "${path.root}/../scripts/99-clean.sh",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.root}/../files/50_growpart_lvm.cfg", {
      diskname = local.diskname
    })
    destination = "/etc/cloud/cloud.cfg.d/50_growpart_lvm.cfg"
    only        = ["proxmox-iso.fedora38"]
  }

  provisioner "file" {
    content = templatefile("${path.root}/../files/50_override_default_user.cfg", {
      default_username = var.default_username
      ssh_keys         = [var.ssh_key]
    })
    destination = "/etc/cloud/cloud.cfg.d/50_override_default_user.cfg"
    only        = ["proxmox-iso.fedora38"]
  }

  provisioner "file" {
    sources = [
      "${path.root}/../files/99_pve.cfg",
    ]
    destination = "/etc/cloud/cloud.cfg.d/"
    only        = ["proxmox-iso.fedora38"]
  }

  provisioner "file" {
    source      = "${path.root}/../files/grow_root.sh"
    destination = "/usr/local/sbin/grow_root"
    only        = ["proxmox-iso.fedora38"]
  }

  # chmod grow_root, remove localhost=fedoratpl from hosts, disable root login
  provisioner "shell" {
    inline = [
      "chmod u+x /usr/local/sbin/grow_root",
      "sed -i /fedoratpl/d /etc/hosts",
      "passwd -l root",
      "sed -e 's/PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config",
    ]
  }
}
