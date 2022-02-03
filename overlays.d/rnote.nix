self: super:
let
  poppler = self.poppler.overrideAttrs (o: rec {
    version = "22.01.0";
    src = self.fetchurl {
      url = "https://poppler.freedesktop.org/poppler-${version}.tar.xz";
      sha256 = "sha256-fTSTBWtbhkE+XGk8LK4CxcBs2OYY0UwsMeLIS2eyMT4=";
    };
  });
  gstreamer = self.gst_all_1.gstreamer.overrideAttrs (o: rec {
    version = "1.18.5";
    src = self.fetchurl {
      url = "https://gstreamer.freedesktop.org/src/${o.pname}/${o.pname}-${version}.tar.xz";
      sha256 = "sha256-VYYiMqY0Wbv1ar694whcqa7CEbR46JHazqTW34yv6Ao=";
    };
  });
in
{
  rnote = self.stdenv.mkDerivation rec {
    pname = "rnote";
    version = "0.3.1";

    src = self.fetchFromGitHub {
      repo = pname;
      owner = "flxzt";
      rev = "v${version}";
      sha256 = "sha256-J+rGPwH1OCOwWHUQmzlsvSh09oKCe4nFGTf6E5zgmvo=";
    };

    cargoDeps = self.rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-2sEIFNxrRGxjUXutSo9ZtsVnkY3BMdQxqkDJQnIxk88=";
    };

    patches = [
      # enables us to use gtk4-update-icon-cache instead of gtk3 one
      ../patches/rnote.patch
    ];



    nativeBuildInputs = with self; [
      pkg-config
      ninja
      meson
      rustPlatform.cargoSetupHook
      rustPlatform.rust.cargo
      rustPlatform.rust.rustc
      desktop-file-utils
      shared-mime-info
      wrapGAppsHook
    ];

    buildInputs = with self; [
      gtk4
      libadwaita
      poppler
      gstreamer
      libxml2
    ];
  };
}
