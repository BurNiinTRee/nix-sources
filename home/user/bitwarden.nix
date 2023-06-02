{...}: {
  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://vault.muehml.eu";
      email = "lars@muehml.eu";
      pinentry = "gnome3";
    };
  };
}
