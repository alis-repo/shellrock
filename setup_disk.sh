#!/usr/bin/bash
#
# DESCRIPTION
# https://goo.gl/FoKRZk

create_os_part(){
  # shellcheck disable=SC2154
  dd bs=512 count=4 if=/dev/urandom of="$luks_keyfile"

  # shellcheck disable=SC2154
  truncate -s 2M "$luks_header"

  # shellcheck disable=SC2154
  cryptsetup  -c "$cipher" luksFormat "$os_part"  --type=luks2 --disable-keyring -y --progress-frequency=1 -t=0 -T=2  --header="$luks_header" --key-file="$luks_keyfile"  --label="$os_label"

  # shellcheck disable=SC2154
  cryptsetup  luksOpen "$os_part" --header="$luks_header" --key-file="$luks_keyfile"  "$luks_device"

  # shellcheck disable=SC2154
  mkfs.btrfs -f --label "$os_label" "/dev/mapper/$luks_device"

  sleep 5
  # shellcheck disable=SC2154
  mount -o "$os_part_opts"  "/dev/mapper/$luks_device" "$mountpoint"
             mkdir -v -p "$mountpoint/archlinux"
             mkdir -v -p "$mountpoint/archlinux/var"
             mkdir -v -p "$mountpoint/archlinux/usr"
  btrfs subvolume create "$mountpoint/archlinux/root"
  btrfs subvolume create "$mountpoint/archlinux/home"
  btrfs subvolume create "$mountpoint/archlinux/srv"
  btrfs subvolume create "$mountpoint/archlinux/opt"
  btrfs subvolume create "$mountpoint/archlinux/usr/local"
  btrfs subvolume create "$mountpoint/archlinux/var/tmp"
  btrfs subvolume create "$mountpoint/archlinux/var/opt"
  btrfs subvolume create "$mountpoint/archlinux/var/log"
  btrfs subvolume create "$mountpoint/archlinux/var/cache"

             mkdir -v -p "$mountpoint/snapshots"
             mkdir -v -p "$mountpoint/snapshots/var"
             mkdir -v -p "$mountpoint/snapshots/usr"
  btrfs subvolume create "$mountpoint/snapshots/snapper_root"
  btrfs subvolume create "$mountpoint/snapshots/snapper_home"
  btrfs subvolume create "$mountpoint/snapshots/snapper_srv"
  btrfs subvolume create "$mountpoint/snapshots/snapper_opt"
  btrfs subvolume create "$mountpoint/snapshots/usr/snapper_local"
  btrfs subvolume create "$mountpoint/snapshots/var/snapper_tmp"
  btrfs subvolume create "$mountpoint/snapshots/var/snapper_opt"
  btrfs subvolume create "$mountpoint/snapshots/var/snapper_log"
  btrfs subvolume create "$mountpoint/snapshots/var/snapper_cache"

  sleep 5
  umount -R "$mountpoint"
  mount -t btrfs -o subvol=/archlinux/root,"$os_part_opts" "/dev/mapper/$luks_device"  "$mountpoint"
  mkdir -p "$mountpoint/boot"
  mkdir -p "$mountpoint/home"
  mkdir -p "$mountpoint/srv"
  mkdir -p "$mountpoint/opt"
  mkdir -p "$mountpoint/tmp"
  mkdir -p "$mountpoint/usr/local"
  mkdir -p "$mountpoint/var/tmp"
  mkdir -p "$mountpoint/var/opt"
  mkdir -p "$mountpoint/var/log"
  mkdir -p "$mountpoint/var/cache"

  mount -t btrfs -o subvol=/archlinux/home,"$os_part_opts"           "/dev/mapper/$luks_device"     "$mountpoint/home"
  mount -t btrfs -o subvol=/archlinux/srv,"$os_part_opts"            "/dev/mapper/$luks_device"     "$mountpoint/srv"
  mount -t btrfs -o subvol=/archlinux/opt,"$os_part_opts"            "/dev/mapper/$luks_device"     "$mountpoint/opt"
  mount -t btrfs -o subvol=/archlinux/usr/local,"$os_part_opts"      "/dev/mapper/$luks_device"     "$mountpoint/usr/local"
  mount -t btrfs -o subvol=/archlinux/var/tmp,"$os_part_opts"        "/dev/mapper/$luks_device"     "$mountpoint/var/tmp"
  mount -t btrfs -o subvol=/archlinux/var/opt,"$os_part_opts"        "/dev/mapper/$luks_device"     "$mountpoint/var/opt"
  mount -t btrfs -o subvol=/archlinux/var/log,"$os_part_opts"        "/dev/mapper/$luks_device"     "$mountpoint/var/log"
  mount -t btrfs -o subvol=/archlinux/var/cache,"$os_part_opts"      "/dev/mapper/$luks_device"     "$mountpoint/var/cache"

  # shellcheck disable=SC2154
  mount -t vfat -o "$esp_part_opts"                                  "$esp_part"        "$mountpoint/boot"
}

create_esp_part(){
  # shellcheck disable=SC2154
  mkfs.vfat -c -n "$esp_label" -F32 "$esp_part"
}

append_parts_table(){
  # shellcheck disable=SC2154
  sfdisk "${os_part::-1}" < "$script_path"/"$script_name"_libs/entire-ESP-OS.dump
}

wipe_fs(){
  wipefs --all "${os_part::-1}"
}

setup_disk(){
  wipe_fs
  append_parts_table
  create_esp_part
  create_os_part
}

export setup_disk
