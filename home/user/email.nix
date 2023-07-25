{...}: {
  programs.thunderbird = {
    enable = true;
    profiles.user.isDefault = true;
  };

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
      # thunderbird.enable = true;
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
      # thunderbird.enable = true;
    };
    "gmail.com" = {
      address = "lukas.lukas2511@googlemail.com";
      realName = "Lars Mühmel";
      userName = "lukas.lukas2511@googlemail.com";
      flavor = "gmail.com";
      # thunderbird.enable = true;
    };
    "lnu.se" = {
      address = "lm222ux@student.lnu.se";
      realName = "Lars Mühmel";
      userName = "lm222ux@student.lnu.se";
      flavor = "gmail.com";
      # thunderbird.enable = true;
    };
  };
}
