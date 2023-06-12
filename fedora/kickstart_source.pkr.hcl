source "file" "kickstart" {
  content = templatefile("${path.root}/templates/ks.cfg.pkr.tpl", {
    root_password   = bcrypt(local.root_password, 6)
    language        = var.language
    timezone        = var.timezone
    vconsole_keymap = var.vconsole_keymap
    keyboard_layout = var.keyboard_layout
    diskname        = local.diskname
    bootargs        = var.bootargs
    netinstall        = var.netinstall
  })
  target = "${path.root}/seed/ks.cfg"
}
