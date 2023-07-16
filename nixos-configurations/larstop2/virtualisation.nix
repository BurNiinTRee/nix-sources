{pkgs, ...}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
    };
  };

  environment.systemPackages = [
    pkgs.virt-manager
  ];
  home-manager.users.user.persist.directories = [".local/share/containers/storage"];
}
