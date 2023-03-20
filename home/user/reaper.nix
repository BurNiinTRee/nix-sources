{pkgs, ...}: {
  home.packages = with pkgs; [
    reaper
  ];
  persist.directories = [".config/REAPER"];
}
