{...}: {
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
  home-manager.users.user.persist.directories = [".local/share/containers/storage"];
}
