{...}: {
  programs.evolution.enable = true;

  home-manager.users.user.persist.directories = [
    ".config/evolution"
    ".local/share/evolution"
  ];
}
