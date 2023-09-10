{config, ...}: {
  users.users.user = {
    description = "Lars Mühmel";
    isNormalUser = true;
    extraGroups = ["wheel" "pipewire"];
    initialHashedPassword = "$y$j9T$/hQLdYUVBDYCQ3LK9F.Yx1$pIFTIidLJotqbprVw1t50PVqQuEG1.FG2lA6WAcfzK7";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5s+IKT2XS2IpsKLXhhBydhBXVbfY3k2Ep8yhPqtB2z user@larstop2"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = config.users.users.user.openssh.authorizedKeys.keys;
}
