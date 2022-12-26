{...}: {
  disko.devices = {
    disk.vda = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "500MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nix";
            type = "partition";
            start = "500MiB";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          }
        ];
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
          "defaults"
          "mode=755"
        ];
      };
    };
  };
}
