{...}: {
  programs.git.enable = true;
  xdg.configFile."git/config".text = ''
    [user]
    email = "lars@muehml.eu"
    name = "Lars Mühmel"
    signingKey = "Lars Mühmel <larsmuehmel@web.de>"

    [init]
    defaultBranch = "main"

    [commit]
    gpgSign = true
  '';
}
