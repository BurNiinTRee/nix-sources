{config, ...}: {
  mailserver = {
    enable = true;
    fqdn = "mail.${config.networking.fqdn}";
    domains = [config.networking.fqdn];

    loginAccounts = {
      "lars@muehml.eu" = {
        hashedPasswordFile = config.age.secrets.emailHashedPassword.path;
        aliases = ["@muehml.eu"];
        catchAll = ["muehml.eu"];
      };
    };
    certificateScheme = "acme-nginx";
  };

  age.secrets.emailHashedPassword.file = ../../secrets/emailHashedPassword.age;
}
