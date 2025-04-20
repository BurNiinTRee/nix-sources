{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()
      local act = wezterm.action

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

      config.mouse_bindings = {
        {
          event = { Up = { streak = 1, button = 'Left' } },
          mods = 'NONE',
          action = act.CompleteSelection 'ClipboardAndPrimarySelection',
        },

        -- and make CTRL-Click open hyperlinks
        {
          event = { Up = { streak = 1, button = 'Left' } },
          mods = 'CTRL',
          action = act.OpenLinkAtMouseCursor,
        },
        -- NOTE that binding only the 'Up' event can give unexpected behaviors.
        -- Read more below on the gotcha of binding an 'Up' event only.
      }


      config.xcursor_theme = xcursor_theme
      config.xcursor_size = xcursor_size

      -- https://github.com/NixOS/nixpkgs/issues/336069#issuecomment-2299008280
      config.front_end = 'WebGpu'

      return config
    '';
  };
}
