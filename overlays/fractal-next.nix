self: super: {
    fractal-next = self.stdenv.mkDerivation rec {
        pname = "fractal-next";
        version = "220209";

        src = self.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "GNOME";
            repo = "fractal";
            rev = "c1f17381ef9f45e78a443b4db21a1f4955f6b49f";
            hash = "sha256-euhzUb0j5hVKZ9mmSppuGDKH+XeTDYuOWNkUDoTWlAs=";
        };

        cargoDeps = self.rustPlatform.fetchCargoTarball {
            inherit src;
            name = "${pname}-0.0.1";
            hash = "sha256-fbzJ7ZOgiROM2R3GnBrTNYO5w4NQIUDUHMPHrdAUYUE=";
        };

        nativeBuildInputs = with self; [
            meson
            ninja
            pkg-config
            desktop-file-utils
            rustPlatform.cargoSetupHook
            rustPlatform.rust.cargo
            rustPlatform.rust.rustc
            # Not in meson.build
            cmake # required for libolm-sys, providing olm from nix doesn't help
            clang # required for bindgen in pipewire
            # Nix specific
            wrapGAppsHook
        ];

        buildInputs = with self; [
            gtk4
            glib
            libadwaita
            gtksourceview5
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            # Not in meson.build
            openssl
            gst_all_1.gst-plugins-bad
            pipewire
        ];

        # Also not in meson.build but maybe nix specific
        LIBCLANG_PATH = "${self.libclang.lib}/lib";
    };
}