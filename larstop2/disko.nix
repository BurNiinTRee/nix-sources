{lib, ...}: {
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        # device = "/dev/vda";
        device = /dev/nvme0n1;
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
                    "/nix" = {
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountOptions = ["compress=zstd" "noatime"];
                    };
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
}
