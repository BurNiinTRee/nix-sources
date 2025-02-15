{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks.muehml = {
      hostname = "muehml.eu";
      user = "root";
    };
  };
  persist.directories = [ ".ssh" ];
}
