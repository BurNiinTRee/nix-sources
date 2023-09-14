{
  scripts,
  nix,
  writeShellApplication,
  stdenv,
  nixos-rebuild,
  selfLocation,
}: let
  ShellApplicationNoCheck = {
    name,
    text,
    runtimeInputs ? [],
  }:
    writeShellApplication {
      inherit name text runtimeInputs;
      checkPhase = ''
        runHook preCheck
        ${stdenv.shellDryRun} "$target"
        runHook postCheck
      '';
    };
in {
  iso = ShellApplicationNoCheck {
    name = "iso";
    runtimeInputs = [nix];
    text = ''
      isoPath=$(nix build ${selfLocation}#larstop2Iso --no-link --print-out-paths)
      if [ -e nixos.iso ]; then
        rm -f nixos.iso
      fi
      cp $isoPath/iso/*.iso nixos.iso
    '';
  };

  update = ShellApplicationNoCheck {
    name = "up";
    runtimeInputs = [scripts.deploy];
    text = ''
      nix flake update --commit-lock-file ${selfLocation}
      deploy
    '';
  };
  deploy = ShellApplicationNoCheck {
    name = "deploy";
    runtimeInputs = [scripts.larstop2 scripts.muehml scripts.rpi];
    text = ''
      larstop2 # home-manager switch
      muehml # deploy to muehml.eu
      rpi # deploy to rpi3
    '';
  };
  larstop2 = ShellApplicationNoCheck {
    name = "larstop2";
    runtimeInputs = [nixos-rebuild];
    text = ''
      sudo nixos-rebuild switch  --flake ${selfLocation} $@
    '';
  };
  muehml = ShellApplicationNoCheck {
    name = "muehml";
    runtimeInputs = [nixos-rebuild];
    text = ''
      nixos-rebuild switch --target-host root@muehml.eu --flake ${selfLocation}#muehml
    '';
  };
  rpi = ShellApplicationNoCheck {
    name = "rpi";
    runtimeInputs = [nixos-rebuild];
    text = ''
      nixos-rebuild switch --target-host root@rpi.local --flake ${selfLocation}#rpi
    '';
  };
  htpc = ShellApplicationNoCheck {
    name = "htpc";
    runtimeInputs = [nixos-rebuild];
    text = ''
      nixos-rebuild switch --target-host root@htpc.local --flake ${selfLocation}#htpc
    '';
  };
}
