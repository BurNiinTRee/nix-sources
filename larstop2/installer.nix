{
  config,
  pkgs,
  lib,
  self,
  ...
}: {
  imports = [./disko.nix];
  disko.enableConfig = false;

  isoImage = {
    compressImage = false;
    squashfsCompression = "zstd -Xcompression-level 1";
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos" ''
      export PATH=${lib.makeBinPath [
        "/run/current-system/sw"
        config.system.build.nixos-install
        pkgs.systemd
        pkgs.btrfs-progs
      ]}
      set -eux

      wipefs --all /dev/vda
      # wipefs --all /dev/nvme0n1

      echo Creating Filesystems
      ${config.system.build.disko} --mode zap_create_mount

      echo Creating empty snapshots
      mkdir -p /mnt/home/user
      btrfs subvolume snapshot -r /mnt/home/ /mnt/empty/home
      btrfs subvolume snapshot -r /mnt /mnt/empty/root

      mkdir -p /mnt/persist/home/user
      cp -r ${self} /mnt/persist/home/user/bntr

      nixos-install --system ${self
        .nixosConfigurations
        .larstop2
        .config
        .system
        .build
        .toplevel} \
        --root /mnt \
        --no-root-passwd
    '')
  ];
}
