{
  lib,
  config,
  ...
}: let
  cfg = config.modules.services;
  inherit (lib) mkIf;
  domain = "isabelroses.com";
in {
  config = {
    networking.domain = domain;

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "isabel@${domain}";
      };
    };

    services.nginx = mkIf cfg.nginx.enable {
      enable = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        # website + other stuff
        "${domain}" = mkIf cfg.isabelroses-web.enable {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };

        # vaultwawrden
        "vault.${domain}" = mkIf cfg.vaultwarden.enable {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        };

        # gitea
        "git.${domain}" = mkIf cfg.gitea.enable {
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
          forceSSL = true;
          enableACME = true;
        };

        "mail.${domain}" = mkIf cfg.mailserver.enable {
          forceSSL = true;
          enableACME = true;
        };
        "webmail.${domain}" = mkIf cfg.mailserver.enable {
          forceSSL = true;
          enableACME = true;
        };

        "search.${domain}" = mkIf cfg.searxng.enable {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8888";
          extraConfig = ''
            access_log /dev/null;
            error_log /dev/null;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
          '';
        };
      };
    };
  };
}
