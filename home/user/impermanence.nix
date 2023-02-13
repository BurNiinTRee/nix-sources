{...}: {
  home.persistence."/persist/home/user" = {
    allowOther = true;
    directories = ["bntr"];
  };
}
