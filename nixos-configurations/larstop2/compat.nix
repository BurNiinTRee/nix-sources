{...}: {
  programs.nix-ld = {
    enable = true;
  };
  services.envfs.enable = true;
  # boot.binfmt.emulatedSystems = [
  #   "aarch64-linux"
  #   "wasm32-wasi"
  #   # "x86_64-windows"
  # ];
}
