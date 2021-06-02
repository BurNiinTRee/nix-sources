self: super: {
  mullvad-vpn = super.mullvad-vpn.overrideAttrs (old: rec {
    version = "2021.3";
    src = self.fetchurl {
      url = "https://github.com/mullvad/mullvadvpn-app/releases/download/${version}/MullvadVPN-${version}_amd64.deb";
      sha256 = "sha256-f7ZCDZ/RN+Z0Szmnx8mbzhKZiRPjqXTsgClfWViFYzo=";
    };
  });
}
