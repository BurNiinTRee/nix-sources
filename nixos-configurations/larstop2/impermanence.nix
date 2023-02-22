{
  lib,
  config,
  options,
  ...
}: {
  options.persist = {
    directories = lib.mkOption {
      type = (options.environment.persistence.type.getSubOptions []).directories.type;
      default = [];
    };
    files = lib.mkOption {
      type = (options.environment.persistence.type.getSubOptions []).files.type;
      default = [];
    };
  };
  config = {
    environment.persistence."/persist/root" = {
      inherit (config.persist) directories files;
    };
    programs.fuse.userAllowOther = true;

    # Reset root to empty partitions
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      set -x
      waitDevice /dev/mapper/crypted
      mkdir /mnt
      mount /dev/mapper/crypted /mnt
      btrfs subvolume delete /mnt/root/var/lib/portables
      btrfs subvolume delete /mnt/root/tmp
      btrfs subvolume delete /mnt/root/srv
      btrfs subvolume delete /mnt/root/var/lib/machines
      btrfs subvolume delete /mnt/root
      btrfs subvolume create /mnt/root
      umount /mnt
      rmdir /mnt
      set +x
    '';
  };
}
