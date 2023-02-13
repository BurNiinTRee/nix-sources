{...}: {
  environment.persistence."/persist/root" = {
    directories = [];
  };
  programs.fuse.userAllowOther = true;
}
