{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.default_prog = { 'nu' }
      config.font = wezterm.font 'Fira Code'
      config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
      config.color_scheme = 'One Light (Gogh)'

      config.hide_mouse_cursor_when_typing = false

      return config
    '';
  };
}
