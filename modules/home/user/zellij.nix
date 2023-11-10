{pkgs, lib, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "zellij-attach" 
    ''
      export PATH="${lib.makeBinPath [pkgs.skim]}:$PATH"

      ZJ_SESSIONS=$(zellij list-sessions)
      NO_SESSIONS=$(echo "''${ZJ_SESSIONS}" | wc -l)

      if [ "''${NO_SESSIONS}" -ge 2 ]; then
          exec zellij attach \
          "$(echo "''${ZJ_SESSIONS}" | sk)"
      else
         exec zellij attach -c
      fi
    '')
  ];
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "nu";
      copy_command = "wl-copy";
      mirror_session = false;
      ui.pane_frames.hide_session_name = true;
      simplified_ui = true;
      keybinds = {
        normal = {
          unbind._args = ["Ctrl g"];
          bind = {
            _args = ["Alt g"];
            SwitchToMode._args = ["locked"];
          };
        };
        locked = {
          unbind._args = ["Ctrl g"];
          bind = {
            _args = ["Alt g"];
            SwitchToMode._args = ["normal"];
          };
        };
      };
      theme = "catppuccin-latte";
      themes = {
        catppuccin-latte = {
          bg = "#acb0be"; # Surface2
          fg = "#acb0be"; # Surface2
          red = "#d20f39";
          green = "#40a02b";
          blue = "#1e66f5";
          yellow = "#df8e1d";
          magenta = "#ea76cb"; # Pink
          orange = "#fe640b"; # Peach
          cyan = "#04a5e5"; # Sky
          black = "#4c4f69"; # Text
          white = "#dce0e8"; # Crust
        };
      };
    };
  };
}
