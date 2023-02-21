{
  config,
  options,
  ...
}: {
  options.persist = {
    directories = (options.home.persistence.type.getSubOptions []).directories;
    files = (options.home.persistence.type.getSubOptions []).files;
  };
  config = {
    home.persistence."/persist/home/user" = {
      allowOther = true;
      inherit (config.persist) files directories;
    };
  };
}
