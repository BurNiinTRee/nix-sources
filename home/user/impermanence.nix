{config, ...}: {
  home.persistence."/persist/home/user" = {
    allowOther = true;
    directories = [
      "bntr"
      "projects"
      ".ssh"
      ".local/share/password-store"
      ".gnupg"
    ];
    files = [
      ".config/monitors.xml"
    ];
  };
}
