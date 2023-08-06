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
    runtimeInputs = [scripts.larstop2 scripts.muehml scripts.htpc];
    text = ''
      larstop2 # home-manager switch
      muehml # deploy to muehml.eu
      # I'm On Vacation
      # htpc # deploy to chromebook
    '';
  };
  larstop2 = ShellApplicationNoCheck {
    name = "larstop2";
    runtimeInputs = [nixos-rebuild];
    text = ''
      sudo nixos-rebuild switch --update-input my-modules  --flake ${selfLocation} $@
    '';
  };
  muehml = ShellApplicationNoCheck {
    name = "muehml";
    runtimeInputs = [nixos-rebuild];
    text = ''
      nixos-rebuild switch --target-host root@muehml.eu --update-input my-modules --flake ${selfLocation}#muehml
    '';
  };
  htpc = ShellApplicationNoCheck {
    name = "htpc";
    runtimeInputs = [nixos-rebuild];
    text = ''
      nixos-rebuild switch --target-host root@htpc.local --update-input my-modules --flake ${selfLocation}#htpc
    '';
  };
}
