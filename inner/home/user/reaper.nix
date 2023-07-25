{pkgs, ...}: {
  home.packages = with pkgs; [
    reaper
    setbfree
  ];
  persist.directories = [".config/REAPER"];
}
