#!/usr/bin/bash
#
# DESCRIPTION
#

check_previous_install(){
  # shellcheck disable=SC2154
  if [ -e "$luks_header" ]; then
    rm "$luks_header";
    msg "Previous header removed";
  fi

  # shellcheck disable=SC2154
  if [ -e "$luks_keyfile" ]; then
    rm "$luks_keyfile";
    msg "Previous keyfile  removed";
  fi

  # shellcheck disable=SC2154
  if mountpoint -q "$mountpoint"; then
    umount -R "$mountpoint";
    msg "Mount point is ready";
  fi

  # shellcheck disable=SC2154
  if [ -e "/dev/mapper/$luks_device" ]; then
    cryptsetup luksClose "$luks_device";
    msg "Close luks device"
  fi
}

create_ranked_mirrorslist(){
  if [ -e "/etc/pacman.d/mirrorlist" ]; then
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  fi
  # shellcheck disable=SC2154
  wget --quiet "https://www.archlinux.org/mirrorlist/?country=$country_code&protocol=https&ip_version=4" -O '/etc/pacman.d/mirrorlist.tmp'
  sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.tmp
  rankmirrors -n 6 /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist
}

sync_sys_time(){
  timedatectl set-ntp true;
}

check_efi_folder(){
  if [ -d "/sys/firmware/efi/efivars" ]; then
    msg "EFI is good";
  else
    die "Efivars folder not available";
  fi
}

check_ping_result(){
  if ping -c 3 www.archlinux.org; then
    msg "Network is good";
  else
    die "Network is bad";
  fi
}

before_install(){
  check_ping_result
  check_efi_folder
  sync_sys_time
  create_ranked_mirrorslist
  check_previous_install
}

export before_install
