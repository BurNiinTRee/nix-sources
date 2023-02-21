let
  # larstop2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsubAF9SruRBOTXRI2nPAMX5I0gD1OOheji91/NGknv lars@install";
  larstop2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5s+IKT2XS2IpsKLXhhBydhBXVbfY3k2Ep8yhPqtB2z user@larstop2";

  muehml = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0uJlajpOA0p387s4n/XeY+oZWhuA6YCMWqRhaxBKc+ root@nixos";
in {
  "nx-initial-admin-pass.age".publicKeys = [larstop2 muehml];
  "pleroma-secrets.age".publicKeys = [larstop2 muehml];
  "emailHashedPassword.age".publicKeys = [larstop2 muehml];
  "atticd.env.age".publicKeys = [larstop2 muehml];
}
