{...}: {
  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "nix";
          formatter.command = "alejandra";
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
          language-servers = ["blueprint-compiler"];
        }
      ];
      language-server = {
        rust-analyzer = {
          config.check.command = "clippy";
        };
        blueprint-compiler = {
          command = "blueprint-compiler";
          args = ["lsp"];
        };
      };
    };
    settings = {
      theme = "onelight";
      editor = {
        color-modes = true;
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        file-picker.hidden = false;
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };
}
