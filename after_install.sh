#!/usr/bin/bash
#
# DESCRIPTION
#

check_previous_install(){
  # shellcheck disable=SC2154
  if [ -e "$luks_header" ]; then
    rm "$luks_header";
    msg "Previous header.img now is good";
    else
    msg "Previous header.img is good";
  fi

  # shellcheck disable=SC2154
  if mountpoint -q "$mountpoint"; then
    umount -R "$mountpoint";
    msg "Mount point now is good";
  else
    msg "Mount point is good";
  fi

  # shellcheck disable=SC2154
  if [ -e "/dev/mapper/$luks_device" ]; then
    cryptsetup luksClose "$luks_device";
    msg "Luks device now is good";
  else
    msg "Luks device is good";
  fi
}

after_install(){
  check_previous_install
}

export after_install
