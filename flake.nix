{
  description = "My Nixos System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "/home/lars/packages/nixpkgs";
    musnix = {
      url = "github:cidkidnix/musnix/flake-rework";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-21.11-small";
    # home-manager = {
    #   url = "github:rycee/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    rnix-flake = {
      url = "gitlab:jD91mZM2/nix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pianoteq = {
      url = "path:/home/lars/Music/Pianoteq-7/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    organteq = {
      url = "path:/home/lars/Music/Organteq-1/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    reaper = {
      url = "path:/home/lars/Music/Reaper/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, musnix, nixpkgs-release, home-manager, rnix-flake, deploy-rs, ... }:
    let
      overlays = (import ./overlays.nix) ++ [
        musnix.overlay
      ];
    in
    {
      legacyPackages.x86_64-linux = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
        config = { allowUnfree = true; };
      };
      inherit (nixpkgs) lib;

      nixosConfigurations."muehml.eu" = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./server
        ];
      };

      nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./rpi
        ];
      };

      # devShell.x86_64-linux = self.legacyPackages.x86_64-linux.mkShell {
      #   name = "nix-sources";
      #   buildInputs = [ inputs.nixos-update-checker.defaultPackage.x86_64-linux ];
      #   shellHook = ''
      #     nixos-update-checker nixos-unstable nixos-20.09-small
      #   '';
      # };

      deploy.nodes."muehml" = {
        hostname = "muehml.eu";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."muehml.eu";
        };
        sshUser = "root";
      };

      # deploy.nodes.rpi = {
      #   hostname = "rpi.local";
      #   profiles.system = {
      #     user = "root";
      #     path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi;
      #   };
      #   sshUser = "root";
      # };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      nixosConfigurations.larstop2 = self.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
            nix = {
              binaryCachePublicKeys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
              binaryCaches = [
                "https://cache.nixos.org"
              ];

              package = pkgs.nixUnstable;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              registry.pkgs = {
                to = {
                  type = "path";
                  path = "/home/lars/nix-sources";
                };
              };
            };
            nixpkgs.overlays = overlays;
            nixpkgs.config = {
              allowUnfree = true;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lars = import ./home.nix inputs;
          })
          ./configuration.nix
          home-manager.nixosModules.home-manager
          musnix.nixosModules.musnix
        ];
      };
      templates = {
        cargo-pijul = {
          path = ./templates/cargo-pijul;
          description = "A template for a simple cargo package built with cargo-import and version controlled with pijul";
        };
      };
    };
}
