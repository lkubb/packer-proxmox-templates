#!/bin/bash

set -e

if [[ ! -d "/etc/cloud/cloud.cfg.d" ]]; then
    mkdir -p "/etc/cloud/cloud.cfg.d"
    chown root: "/etc/cloud/cloud.cfg.d"
    chmod 755 "/etc/cloud/cloud.cfg.d"
fi

cat <<'EOF' > /etc/cloud/cloud.cfg.d/99_pve.cfg
datasource_list: [ NoCloud, ConfigDrive ]
EOF

# this is mostly the debian default atm

cat <<'EOF' > /etc/cloud/cloud.cfg
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below

users:
  - default

# If this is set, 'root' will not be able to ssh in and they
# will get a message to login instead as the above $user (debian)
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# This prevents cloud-init from rewriting apt's sources.list file,
# which has been a source of surprise.
apt_preserve_sources_list: true

EOF

cat <<EOF >> /etc/cloud/cloud.cfg
growpart:
  mode: "growpart"
  # since default setup creates an extended partition,
  # we need to resize it along with the lvm one
  devices:
    - "/dev/${DISK_NAME}2"
    - "/dev/${DISK_NAME}5"

# cloud-init does not handle resizing of lvm atm
runcmd:
  - [ cloud-init-per, once, grow_VG, pvresize, /dev/${DISK_NAME}5 ]
  - [ cloud-init-per, once, grow_LV, lvextend, -l, +100%FREE, /dev/debian-vg/root ]
  - [ cloud-init-per, once, grow_FS, resize2fs, /dev/debian-vg/root ]

EOF

cat <<'EOF' >> /etc/cloud/cloud.cfg
# Example datasource config
# datasource:
#    Ec2:
#      metadata_urls: [ 'blah.com' ]
#      timeout: 5 # (defaults to 50 seconds)
#      max_wait: 10 # (defaults to 120 seconds)

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - disk_setup
 - mounts
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
 - emit_upstart
 - ssh-import-id
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - ntp
 - timezone
 - disable-ec2-metadata
 - runcmd
 - byobu

# The modules that run in the 'final' stage
cloud_final_modules:
 - package-update-upgrade-install
 - fan
 - puppet
 - chef
 - salt-minion
 - mcollective
 - rightscale_userdata
 - scripts-vendor
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
 - power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
   # This will affect which distro class gets used
   distro: debian
EOF

cat <<EOF >> /etc/cloud/cloud.cfg
   # Default user name + that default users groups (if added/used)
   # default_user:
   #   name: debian
   #   lock_passwd: True
   #   gecos: Debian
   #   groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
   #   sudo: ["ALL=(ALL) NOPASSWD:ALL"]
   #   shell: /bin/bash
   # Other config here will be given to the distro class and/or path classes
   default_user:
     name: ${DEFAULT_USERNAME}
     gecos: ${DEFAULT_USERNAME}
     groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
     lock_passwd: false
     ssh_authorized_keys:
       - "${SSH_KEY}"
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
      upstart_dir: /etc/init/
   package_mirrors:
     - arches: [default]
       failsafe:
         primary: http://deb.debian.org/debian
         security: http://security.debian.org/
   ssh_svcname: ssh
EOF
