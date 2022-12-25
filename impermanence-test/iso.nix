{
  config,
  pkgs,
  lib,
  installedSystem,
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

      mkdir -p /mnt/nix/persist


      install -D ${./configuration.nix} /mnt/nix/persist/etc/nixos/configuration.nix
      install -D ${./disko.nix} /mnt/nix/persist/etc/nixos/disko.nix
      nixos-generate-config --no-filesystems --show-hardware-config --root /mnt > /mnt/nix/persist/etc/nixos/hardware-configuration.nix
      cat > /mnt/nix/persist/etc/nixos/flake.nix <<EOF
      {
        inputs = {
          nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
          impermanence.url = "github:nix-community/impermanence";
          disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
          };
        };
        outputs = {self, nixpkgs, disko, impermanence}: {
          nixosConfigurations.impermanent = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./configuration.nix
              disko.nixosModules.disko
              impermanence.nixosModule
            ];
          };
        };
      }
      EOF

      ${config.system.build.nixos-install}/bin/nixos-install \
        --system ${
        installedSystem
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
