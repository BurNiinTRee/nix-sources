{config, ...}: {
  home.persistence."/persist/home/user" = {
    allowOther = true;
    directories = [
      "bntr"
      "projects"
      ".ssh"
      "${config.programs.password-store.settings.PASSWORD_STORE_DIR}"
    ];
    files = [
      ".config/monitors.xml"
    ];
  };
}
