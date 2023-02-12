{...}: {
  programs.offlineimap.enable = true;
  programs.msmtp.enable = true;

  programs.aerc = {
    enable = true;
    extraConfig.general.unsafe-accounts-conf = true;
  };
  xdg.configFile."aerc/binds.conf".enable = false;
  xdg.configFile."aerc/aerc.conf".enable = false;

  accounts.email.accounts = let
    pass = acc: "pass show ${acc}";
    folders = acc: {
      drafts = "DRAFTS";
      inbox = "INBOX";
      sent = "SENT";
      trash = "TRASH";
    };
  in {
    "muehml.eu" = {
      address = "lars@muehml.eu";
      primary = true;
      realName = "Lars Mühmel";
      userName = "lars@muehml.eu";
      imap.host = "mail.muehml.eu";
      smtp.host = "mail.muehml.eu";
      passwordCommand = pass "mail.muehml.eu/lars@muehml.eu";
      offlineimap.enable = true;
      msmtp.enable = true;
      aerc.enable = true;
    };
    "web.de" = {
      address = "larsmuehmel@web.de";
      realName = "Lars Mühmel";
      userName = "larsmuehmel@web.de";
      folders = {
        drafts = "DRAFTS";
        sent = "SENT";
        trash = "TRASH";
      };
      passwordCommand = pass "web.de/larsmuehmel@web.de";
      imap.host = "imap.web.de";
      smtp.host = "smtp.web.de";
      aerc.enable = true;
      offlineimap.enable = true;
      msmtp.enable = true;
    };
    "gmail.com" = {
      address = "lukas.lukas2511@googlemail.com";
      realName = "Lars Mühmel";
      userName = "lukas.lukas2511@googlemail.com";
      flavor = "gmail.com";
      folders = {
        sent = "[Gmail].Gesendet";
        drafts = "[Gmail].Entwürfe";
        trash = "[Gmail].Papierkorb";
      };
      offlineimap.enable = true;
      offlineimap.extraConfig.remote = {
        oauth2_client_id_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-id"]).decode()'';
        oauth2_client_secret_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-secret"]).decode()'';
        oauth2_refresh_token_eval = ''get_pass(0,["pass", "show", "google.com/lukas.lukas2511@googlemail.com-email-refresh-token"]).decode()'';
        oauth2_request_url = "https://accounts.google.com/o/oauth2/token";
      };
      aerc.enable = true;
    };
    "lnu.se" = {
      address = "lm222ux@student.lnu.se";
      realName = "Lars Mühmel";
      userName = "lm222ux@student.lnu.se";
      flavor = "gmail.com";
      folders = {
        sent = "[Gmail].Skickat";
        drafts = "[Gmail].Utkast";
        trash = "[Gmail].Papperskorgen";
      };
      offlineimap.enable = true;
      offlineimap.extraConfig.remote = {
        oauth2_client_id_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-id"]).decode()'';
        oauth2_client_secret_eval = ''get_pass(0,["pass", "show", "cloud.google.com/offline-imap-lars-secret"]).decode()'';
        oauth2_refresh_token_eval = ''get_pass(0,["pass", "show", "lnu.se/lm222ux-email-refresh-token"]).decode()'';
        oauth2_request_url = "https://accounts.google.com/o/oauth2/token";
      };
      aerc.enable = true;
    };
  };
}
