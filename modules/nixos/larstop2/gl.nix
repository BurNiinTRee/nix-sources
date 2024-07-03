{pkgs, ...}: {
  # Enable GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
    ];
  };
}
