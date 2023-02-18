{...}:{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
  persist.directories = [
    ".gnupg"
  ];
}
