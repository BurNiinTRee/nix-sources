{ ... }:
{
  programs.password-store = {
    enable = true;
  };
  persist.directories = [ ".local/share/password-store" ];
}
