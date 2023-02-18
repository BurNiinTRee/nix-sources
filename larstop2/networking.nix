{...}: {
  networking.hostName = "larstop2"; # Define your hostname.
  services.avahi = {
    enable = true;
    nssmdns = true;
    allowPointToPoint = true;
    interfaces = ["enp57s0f1" "wlp58s0"];
    openFirewall = true;
  };
  # networking.useDHCP = false;
  # networking.interfaces.enp57s0f1.useDHCP = true;
  # networking.interfaces.wlp58s0.useDHCP = true;


  persist.directories = [
    "/var/lib/NetworkManager"
  ];
  networking.wireguard.enable = true;

  services.mullvad-vpn.enable = true;
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
