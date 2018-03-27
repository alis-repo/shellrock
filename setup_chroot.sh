#!/usr/bin/bash
#
# DESCRIPTION
#

update_configs(){
  # shellcheck disable=SC2154
  cd "$script_path"/"$script_name"_files/configs || return;
  cp --backup=simple --suffix=".bakup" --parent -arv ./* -t /mnt
}

  generate_locales(){
  # shellcheck disable=SC2154
  arch-chroot "$mountpoint" locale-gen
}

setup_rollback(){
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c root      create-config -t root /
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c home      create-config -t default /home
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c srv       create-config -t default /srv
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c opt       create-config -t default /opt
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c usr_local create-config -t default /usr/local
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c var_tmp   create-config -t default /var/tmp
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c var_opt   create-config -t default /var/opt
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c var_log   create-config -t default /var/log
  arch-chroot "$mountpoint"  snapper -v --no-dbus -c var_cache create-config -t default /var/cache

  arch-chroot "$mountpoint"  btrfs subvolume delete /.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /home/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /srv/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /opt/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /usr/local/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /var/tmp/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /var/opt/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /var/log/.snapshots
  arch-chroot "$mountpoint"  btrfs subvolume delete /var/cache/.snapshots

  arch-chroot "$mountpoint"  mkdir -v -p /.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /home/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /srv/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /opt/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /usr/local/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /var/tmp/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /var/opt/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /var/log/.snapshots
  arch-chroot "$mountpoint"  mkdir -v -p /var/cache/.snapshots

  arch-chroot "$mountpoint"  chmod 750 /.snapshots
  arch-chroot "$mountpoint"  chmod 750 /home/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /srv/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /opt/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /usr/local/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /var/tmp/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /var/opt/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /var/log/.snapshots
  arch-chroot "$mountpoint"  chmod 750 /var/cache/.snapshots

  # shellcheck disable=SC2154
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/snapper_root,"$os_part_opts"        "/dev/mapper/$luks_device"   /.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/snapper_home,"$os_part_opts"        "/dev/mapper/$luks_device"   /home/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/snapper_srv,"$os_part_opts"         "/dev/mapper/$luks_device"   /srv/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/snapper_opt,"$os_part_opts"         "/dev/mapper/$luks_device"   /opt/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/usr/snapper_local,"$os_part_opts"   "/dev/mapper/$luks_device"   /usr/local/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/var/snapper_tmp,"$os_part_opts"     "/dev/mapper/$luks_device"   /var/tmp/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/var/snapper_opt,"$os_part_opts"     "/dev/mapper/$luks_device"   /var/opt/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/var/snapper_log,"$os_part_opts"     "/dev/mapper/$luks_device"   /var/log/.snapshots
  arch-chroot "$mountpoint"  mount -t btrfs -o subvol=/snapshots/var/snapper_cache,"$os_part_opts"   "/dev/mapper/$luks_device"   /var/cache/.snapshots

  arch-chroot "$mountpoint"  btrfs subvolume set-default 257 /
}

setup_kernels(){
  # shellcheck disable=SC2154
  mv "$luks_header"  "$mountpoint/boot"
  # shellcheck disable=SC2154
  mv "$luks_keyfile" "$mountpoint"
  arch-chroot "$mountpoint" mkinitcpio -p linux
}

setup_bootloader(){
  arch-chroot "$mountpoint" bootctl install
}

setup_services(){
  arch-chroot "$mountpoint" systemctl enable systemd-networkd.service
  arch-chroot "$mountpoint" systemctl enable systemd-resolved.service
  arch-chroot "$mountpoint" systemctl enable wpa_supplicant@wireless0.service
  arch-chroot "$mountpoint" systemctl enable wpa_supplicant-wired@wired0.service
  ln -sf /run/systemd/resolve/resolv.conf /mnt/etc/resolv.conf

  arch-chroot "$mountpoint" systemctl enable powertop.service

  arch-chroot "$mountpoint" rm --verbose  -rf /etc/{machine-id,localtime,hostname,shadow,locale.conf}
  arch-chroot "$mountpoint" systemctl enable systemd-firstboot.service
}

setup_pacman(){
  arch-chroot "$mountpoint" pacman-key --init
  arch-chroot "$mountpoint" pacman-key --populate archlinux
  arch-chroot "$mountpoint" pacman-optimize
}

setup_users(){
  arch-chroot "$mountpoint" chsh --shell=/bin/zsh root
  arch-chroot "$mountpoint" cp /etc/skel/.zshrc ~/
}

generate_fstab(){
  genfstab -U -p "$mountpoint" >> "$mountpoint/etc/fstab"
}

update_bases(){
  arch-chroot "$mountpoint" pkgfile --update
}

check_permissions(){
  arch-chroot "$mountpoint" chown -c root:root /etc/sudoers.d/10_custom
  arch-chroot "$mountpoint" chmod -c 0440 /etc/sudoers.d/10_custom
  arch-chroot "$mountpoint" chmod 1777 /var/tmp
}

setup_chroot(){
  update_configs
  generate_locales
  setup_rollback
  setup_kernels
  setup_bootloader
  setup_services
  setup_pacman
  setup_users
  generate_fstab
  update_bases
  check_permissions
}

export setup_chroot
