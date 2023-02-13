{lib, ...}: {
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              type = "partition";
              name = "ESP";
              start = "1MiB";
              end = "512MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            }
            {
              type = "partition";
              name = "luks";
              start = "512MiB";
              end = "-32GiB";
              content = {
                type = "luks";
                name = "crypted";
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                    };
                    "/home" = {};
                    "/nix" = {
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/empty" = {};
                  };
                };
              };
            }
            {
              name = "swap";
              type = "partition";
              start = "-32GiB";
              end = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            }
          ];
        };
      };
    };
  };
  # Reset root and home to empty partitions
  # hopefully
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir volumes
    mount /dev/mapper/crypted volumes
    btrfs subvolume delete volumes/home
    btrfs subvolume delete volumes/root
    btrfs subvolume snapshot volumes/empty/home volumes/home
    btrfs subvolume snapshot volumes/empty/root volumes/root
    umount volumes
  '';
}
