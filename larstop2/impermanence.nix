{lib, ...}: {
  environment.persistence."/persist/root" = {
    directories = [];
  };
  programs.fuse.userAllowOther = true;

  # Reset root to empty partitions
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    set -x
    waitDevice /dev/mapper/crypted
    mkdir /mnt
    mount /dev/mapper/crypted /mnt
    btrfs subvolume delete /mnt/root{/srv,/var/lib/machines,}
    btrfs subvolume create /mnt/root
    umount /mnt
    rmdir /mnt
    set +x
  '';
}
