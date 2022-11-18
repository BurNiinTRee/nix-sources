let
  larstop2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOsubAF9SruRBOTXRI2nPAMX5I0gD1OOheji91/NGknv lars@install";

  muehml = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0uJlajpOA0p387s4n/XeY+oZWhuA6YCMWqRhaxBKc+ root@nixos";

in
{
  "nx-initial-admin-pass.age".publicKeys = [ larstop2 muehml ];
}