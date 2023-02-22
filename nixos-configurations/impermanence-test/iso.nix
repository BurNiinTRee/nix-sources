{
  config,
  pkgs,
  lib,
  self,
  ...
}: {
  imports = [./disko.nix];
  disko.enableConfig = false;

  isoImage.compressImage = false;
  # isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";

  systemd.services.install = {
    description = "Bootstrap a Nixos install with impermanence";
    wantedBy = ["mutli-user.target"];
    after = ["network.target" "polkit.service"];
    path = ["/run/current-system/sw" pkgs.parted];
    script = with pkgs; ''
      echo 'journalctl -fb -n100 -uinstall' >>~nixos/.bash_history
      set -eux

      wipefs --all /dev/vda
      ${config.system.build.disko} --mode zap_create_mount

      mkdir -p /mnt/nix/persist/etc/


      cp -r ${self} /mnt/nix/persist/etc/nixos
      nixos-generate-config --no-filesystems --show-hardware-config --root /mnt > /mnt/nix/persist/etc/nixos/impermanence-test/hardware-configuration.nix

      ${config.system.build.nixos-install}/bin/nixos-install \
        --system ${
        self
        .nixosConfigurations
        .impermanence-test
        .config
        .system
        .build
        .toplevel
      } \
        --root /mnt \
        --no-root-passwd


      echo Syncing filesystems
      sync
      echo Shutting off...
      ${systemd}/bin/shutdown now
    '';
    environment =
      config.nix.envVars
      // {
        HOME = "/root";
      };
    serviceConfig = {Type = "oneshot";};
  };
  system.stateVersion = "23.05";
  users.users.root.initialHashedPassword = "";
}
