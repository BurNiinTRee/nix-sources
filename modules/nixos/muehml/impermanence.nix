{
  config,
  options,
  ...
}: {
  options = {
    impermanence.directories = (options.environment.persistence.type.getSubOptions []).directories;
    impermanence.files = (options.environment.persistence.type.getSubOptions []).files;
  };
  config = {
    fileSystems."/mnt/persist" = {
      neededForBoot = true;
      device = "/dev/disk/by-id/scsi-0HC_Volume_100964436";
      fsType = "ext4";
      options = ["discard,defaults,noatime"];
    };

    environment.persistence."/mnt/persist" = {
      files = config.impermanence.files;
      directories =
        [
          "/var/lib/postgresql"
        ]
        ++ config.impermanence.files;
    };
  };
}
