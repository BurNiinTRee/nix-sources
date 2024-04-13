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

      local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"})
      if success then
        config.xcursor_theme = stdout:gsub("'(.+)'\n", "%1")
      end

      local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-size"})
      if success then
        config.xcursor_size = tonumber(stdout)
      end

      config.xcursor_theme = xcursor_theme
      config.xcursor_size = xcursor_size
      return config
    '';
  };
}
