# Fedora Packer Template for Proxmox VE

## Pkrvars

All variables for a specific template are listed in its corresponding `variables.pkr.hcl` file. Some provide an example `my.pkrvars.example.hcl` file. If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

### Required

See the [main README](../README.md).

### Optional

The following lists Fedora-specific variables. See the [main README](../README.md) for common ones.

```hcl
# The X (keyboard) layout to use, see man setxkbmap
keyboard_layout = "us"
# The VConsole keymap to use, see `man setxkbmap`
vconsole_keymap = "us"
# Optional Kernel boot arguments to configure.
# The following defaults ensure compatibility with a PVE serial terminal
bootargs = [
    "systemd.journald.forward_to_console=1",
    "console=ttyS0,38400",
    "console=tty1",
]
# The type of bootloader on the ISO (syslinux or grub2).
# Required to send the correct bootcmd. `syslinux` / `grub2`
iso_bootloader = "grub2"
# Whether the ISO is/should be a netinstall image
netinstall = true
```

## Kickstart File
For automation of Fedora installation, a [Kickstart](https://en.wikipedia.org/wiki/Kickstart_(Linux)) file is required. A default (templated) one is provided.
