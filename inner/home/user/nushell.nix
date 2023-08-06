{
  config,
  pkgs,
  ...
}: {
  programs.nushell = {
    enable = true;
    extraConfig = ''
      let carapace_completer = {|spans|
          carapace $spans.0 nushell $spans | from json
      }
      $env.config = {
        completions: {
          external: {
            enable:  true
            max_results: 100
            completer: $carapace_completer
          }
        }
        hooks: {
          command_not_found: {
            |cmd_name| (
              try {
                ${pkgs.writeScript "command-not-found" ''
                  #!${pkgs.bash}/bin/bash
                  source ${config.programs.nix-index.package}/etc/profile.d/command-not-found.sh
                  command_not_found_handle "$@"
                ''} $cmd_name
              }
            )
          }
        }
      }
    '';
  };

  home.packages = [
    pkgs.carapace
  ];
}
