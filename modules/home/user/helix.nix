{...}: {
  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        formatter.command = "alejandra";
      }
      {
        name = "rust";
        config.check.command = "clippy";
      }
      {
        name = "blueprint";
        file-types = ["blp"];
        indent = {
          tab-width = 2;
          unit = " ";
        };
        scope = "text.blp";
        roots = ["meson.build"];
        comment-token = "//";
        language-server = {
          command = "blueprint-compiler";
          args = ["lsp"];
        };
      }
    ];
    settings.theme = "onelight";
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };
}
