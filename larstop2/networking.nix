{...}: {
  networking.hostName = "larstop2"; # Define your hostname.
  services.avahi = {
    enable = true;
    nssmdns = true;
    allowPointToPoint = true;
    interfaces = ["enp57s0f1" "wlp58s0"];
    openFirewall = true;
  };
  networking.useDHCP = false;
  networking.interfaces.enp57s0f1.useDHCP = true;
  networking.interfaces.wlp58s0.useDHCP = true;
  # Open ports in the firewall.
  # for gsconnect
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  networking.wireguard.enable = true;

  services.mullvad-vpn.enable = true;
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
