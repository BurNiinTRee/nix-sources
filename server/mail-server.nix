{ config, pkgs, ... }:
let domain = "muehml.eu";
in
{
  services.nginx.virtualHosts = {
    "mail.${domain}" = {
      forceSSL = true;
      enableACME = true;
    };
  };
  # See https://www.digitalocean.com/community/tutorials/how-to-set-up-a-postfix-e-mail-server-with-dovecot
  services.postfix = {
    enable = true;
    enableSubmission = true;
    submissionOptions = {
      syslog_name = "postfix/submission";
      smtpd_tls_wrappermode = "no";
      smtpd_tls_security_level = "encrypt";
      smtpd_sasl_auth_enable = "yes";
      smtpd_recipient_restrictions = "permit_mynetworks,permit_sasl_authenticated,reject";
      milter_macro_daemon_name = "ORIGINATING";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
    };
    hostname = "mail.${domain}";
    origin = "mail.${domain}";
    domain = domain;
    destination = [ "mail.${domain}" domain "localhost" ];
    extraConfig = ''
      smtpd_tls_cert_file=/var/lib/acme/mail.${domain}/cert.pem
      smtpd_tls_key_file=/var/lib/acme/mail.${domain}/key.pem
      smtpd_use_tls=yes
      smtpd_tls_session_cache_database=btree:''${data_directory}/smtpd_scache
      smtp_tls_session_cache_database=btree:''${data_directory}/smtp_scache
      smtpd_tls_protocols=!SSLv2, !SSLv3
      local_recipient_maps=proxy:unix:passwd.byname $alias_maps
      smtpd_sasl_path = private/auth
      smtpd_sasl_auth_enable = yes
    '';
    postmasterAlias = "lars";
  };

  services.dovecot2 = {
    enable = true;
    sslServerCert = "/var/lib/acme/mail.${domain}/cert.pem";
    sslServerKey = "/var/lib/acme/mail.${domain}/key.pem";
    extraConfig = ''
      ssl=required
      service auth {
        unix_listener /var/lib/postfix/queue/private/auth {
          mode = 0660
          user = postfix
          group = postfix
        }
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 25 143 465 587 993 ];
  users.users.lars = { isNormalUser = true; };
  environment.systemPackages = [ pkgs.file ];
}
