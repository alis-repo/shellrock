#!/usr/bin/bash
#
# DESCRIPTION
#
pacstrap_chroot(){
  # shellcheck disable=SC2154
  pacstrap  -C "$script_path"/"$script_name"_files/configs/etc/alis/pacstrap.conf \
                                                    "$mountpoint" base systemd-swap crda polkit linux linux-headers mkinitcpio \
                                                    btrfs-progs snapper snapper-gui-git intel-ucode vulkan-intel libva-intel-driver broadcom-wl-dkms wpa_supplicant \
                                                    wpa_supplicant_gui terminus-font ttf-dejavu ttf-hack  zsh zsh-completions zsh-syntax-highlighting bash-completion \
                                                    gzip sed lzop nano iputils sudo wget efibootmgr efitools sbsigntools \
                                                    man iproute2 pkgfile xdelta3 grc modprobed-db plymouth systemd-boot-password \
                                                    libcanberra-pulse libcanberra-gstreamer gst-plugins-base gst-plugins-good gst-libav profile-sync-daemon  \
                                                    epiphany gnome-keyring weston xorg-server-xwayland qt5-wayland qt5-svg gimp-gtk3-git gnome-mpv-git youtube-dl \
                                                    atomicparsley python-crypto pcmanfm-gtk3 xarchiver pulseaudio pulseaudio-bluetooth pulseaudio-zeroconf \
                                                    pulseaudio-lirc pavucontrol pulseeffects calf lsp-plugins-lv2-bin  swh-plugins rubberband zam-plugins-git
}

export pacstrap_chroot
