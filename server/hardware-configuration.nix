# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.initrd.kernelModules = ["virtio_balloon" "virtio_console" "virtio_rng"];

  boot.initrd.postDeviceCommands = ''
    # Set the system time from the hardware clock to work around a
    # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
    # to the *boot time* of the host).
    hwclock -s
  '';

  boot.initrd.availableKernelModules = [
    "9p"
    "9pnet_virtio"
    "ata_piix"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
    "virtio_mmio"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/99f5d718-9926-4ffc-92cd-b6546db5409a";
    fsType = "ext4";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/8d34a338-6040-47ca-8e56-d6bc7be80c7a";}];

  nix.settings.max-jobs = lib.mkDefault 1;
}
