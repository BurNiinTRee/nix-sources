{...}: {
  programs.git = {
    enable = true;
    delta.enable = true;
    signing = {
      signByDefault = true;
      key = "Lars Mühmel <larsmuehmel@web.de>";
    };
    userName = "Lars Mühmel";
    userEmail = "larsmuehmel@web.de";
    extraConfig = {
      init.defaultBranch = "main";
      commit = {
        verbose = true;
      };
      merge.conflictStyle = "zdiff3";
    };
  };
}
