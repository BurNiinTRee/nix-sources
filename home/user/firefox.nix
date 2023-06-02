{...}: {
  programs.browserpass = {
    enable = true;
    browsers = ["firefox"];
  };
  programs.firefox = {
    enable = true;
  };
  home.file.".mozilla/firefox/profiles.ini".text = ''
    [Profile0]
    Name=default
    IsRelative=1
    Path=e0b6u9y0.default
    Default=1

    [General]
    StartWithLastProfile=1
    Version=2
  '';
  persist.directories = [
    ".mozilla/firefox/e0b6u9y0.default"
  ];
}
