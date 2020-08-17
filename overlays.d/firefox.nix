self: pkgs:

{
  firefox-wayland-pipewire-unwrapped = pkgs.firefoxPackages.firefox.overrideAttrs (old: rec {
    buildInputs = old.buildInputs ++ [ pkgs.pipewire ];

    patches = old.patches ++ [
      ((pkgs.fetchpatch {
        url =
          "https://src.fedoraproject.org/rpms/firefox/raw/e99b683a352cf5b2c9ff198756859bae408b5d9d/f/firefox-pipewire-0-3.patch";
        sha256 = "sha256-S7Wv29jfgW0J+S8GpOv54sGc5Kdsdio8PXkIVGIThmE=";
      }))
    ];

    postPatch = ''
      substituteInPlace media/webrtc/trunk/webrtc/modules/desktop_capture/desktop_capture_generic_gn/moz.build \
      --replace /usr/include ${pkgs.pipewire.dev}/include
    '' + old.postPatch;
  });
}
