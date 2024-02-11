{pkgs, ...}: {
  home.packages = [
    (pkgs.runCommand "sharkfox" {} ''
      install -Dm444 ${./watershark.png} $out/share/icons/hicolor/256x256/apps/watershark.png
    '')
  ];
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg.speechSynthesisSupport = true;
      icon = "watershark";
    };
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
