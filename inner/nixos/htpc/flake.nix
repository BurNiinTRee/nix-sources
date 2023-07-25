{
  description = "A very basic flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations.htpc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./slim.nix
        ./big.nix
      ];
    };
  };
}
