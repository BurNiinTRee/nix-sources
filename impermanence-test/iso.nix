{
  config,
  pkgs,
  lib,
  installedSystem,
  ...
}: {
  systemd.services.install = {
    description = "Bootstrap a Nixos install with impermanence";
    wantedBy = ["mutli-user.target"];
    after = ["network.target" "polkit.service"];
    path = ["/run/current-system/sw" pkgs.parted];
    script = with pkgs; ''
      set -eux

      dev=/dev/vda

      wipefs -a ''${dev}
      parted ''${dev} -- mklabel gpt

      parted ''${dev} -- mkpart BOOT fat32 0 512MiB
      parted ''${dev} -- set 1 esp on
      parted ''${dev} -- mkpart nix ext4 512MiB 100%

      mkfs.vfat -F32 -n BOOT ''${dev}1
      mkfs.ext4 -L nix ''${dev}2

      sync

      mkdir /mnt

      mount -t tmpfs none /mnt

      mkdir -p /mnt/{boot,nix,etc/nixos}

      mount ''${dev}1 /mnt/boot
      mount ''${dev}2 /mnt/nix

      mkdir -p /mnt/nix/persist/system

      install -D ${./configuration.nix} /mnt/nix/persist/system/etc/nixos/configuration.nix
      install -D ${./hardware-configuration.nix} /mnt/nix/persist/system/etc/nixos/hardware-configuration.nix

      ${config.system.build.nixos-install}/bin/nixos-install \
        --system ${
        (installedSystem)
        .config
        .system
        .build
        .toplevel
        } \
        --no-root-passwd

      echo Shutting off...
      ${systemd}/bin/shutdown now
    '';
    environment = config.nix.envVars // {
      HOME = "/root";
    };
    serviceConfig = { Type = "oneshot"; };
  };
  system.stateVersion = "23.05";
  users.users.root.initialHashedPassword = "";
}
