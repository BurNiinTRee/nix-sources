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
      }
    '';
  };

  home.packages = [
    pkgs.carapace
  ];
}
