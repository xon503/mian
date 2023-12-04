{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.networking) domain;
  inherit (lib) mkIf template;
  cfg = config.modules.services.mailserver;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  config = mkIf cfg.enable {
    # required for roundcube
    networking.firewall.allowedTCPPorts = [80 443];

    systemd.services = let
      template = {after = ["sops-nix.service"];};
    in {
      roundcube = template;
      mailserver = template;
    };

    mailserver = {
      enable = true;
      openFirewall = true;

      # make sure the perms here is
      # /srv/storage/mail/ # 775
      mailDirectory = "/srv/storage/mail/vmail"; # 770
      dkimKeyDirectory = "/srv/storage/mail/dkim"; # 775
      sieveDirectory = "/srv/storage/mail/sieve"; # 770

      # Enable STARTTLS
      enableImap = true;
      enableImapSsl = true;

      # eww
      enablePop3 = false;
      enablePop3Ssl = false;

      enableSubmission = false;
      enableSubmissionSsl = true;

      # Enable ManageSieve so that we don't need to change the config to update sieves
      enableManageSieve = true;

      # DKIM Settings
      dkimBodyCanonicalization = "relaxed";
      dkimHeaderCanonicalization = "relaxed";
      dkimKeyBits = 4096;
      dkimSelector = "mail";
      dkimSigning = true;

      hierarchySeparator = "/";
      localDnsResolver = false;
      fqdn = "mail.${domain}";
      certificateScheme = "acme-nginx";
      domains = ["${domain}"];

      # Set all no-reply addresses
      rejectRecipients = [
        "noreply@${domain}"
      ];

      loginAccounts = {
        "isabel@${domain}" = {
          hashedPasswordFile = config.sops.secrets.mailserver-isabel.path;
          aliases = [
            "isabel"
            "isabelroses"
            "isabelroses@${domain}"
            "bell"
            "bell@${domain}"
            "me@${domain}"
            "admin"
            "admin@${domain}"
            "root"
            "root@${domain}"
            "postmaster"
            "postmaster@${domain}"
          ];
        };

        "git@${domain}" = {
          aliases = ["git" "git@${domain}"];
          hashedPasswordFile = config.sops.secrets.mailserver-git.path;
        };

        "vaultwarden@${domain}" = {
          aliases = ["vaultwarden" "bitwarden" "bitwarden@${domain}"];
          hashedPasswordFile = config.sops.secrets.mailserver-vaultwarden.path;
        };

        "grafana@${domain}" = {
          aliases = ["grafana" "monitor" "monitor@${domain}"];
          hashedPasswordFile = config.sops.secrets.mailserver-grafana.path;
        };

        "noreply@${domain}" = {
          aliases = ["noreply"];
          hashedPasswordFile = config.sops.secrets.mailserver-noreply.path;
        };

        "spam@${domain}" = {
          aliases = ["spam" "shush" "shush@${domain}" "stfu" "stfu@${domain}"];
          hashedPasswordFile = config.sops.secrets.mailserver-spam.path;
        };
      };

      mailboxes = {
        Archive = {
          auto = "subscribe";
          specialUse = "Archive";
        };
        Drafts = {
          auto = "subscribe";
          specialUse = "Drafts";
        };
        Sent = {
          auto = "subscribe";
          specialUse = "Sent";
        };
        Junk = {
          auto = "subscribe";
          specialUse = "Junk";
        };
        Trash = {
          auto = "subscribe";
          specialUse = "Trash";
        };
      };

      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        # this only applies to plain text attachments, binary attachments are never indexed
        indexAttachments = true;
        enforced = "body";
      };
    };

    services = {
      roundcube = {
        enable = true;

        package = pkgs.roundcube.withPlugins (
          plugins:
            with plugins; [
              persistent_login
              carddav
            ]
        );

        # database = {
        #   host = "/run/postgresql";
        #   password = "";
        # };
        maxAttachmentSize = 50;

        dicts = with pkgs.aspellDicts; [en];

        plugins = [
          "carddav"
          "persistent_login"
        ];

        # this is the url of the vhost, not necessarily the same as the fqdn of the mailserver
        hostName = "webmail.${domain}";
        extraConfig = ''
          $config['imap_host'] = array(
            'ssl://${config.mailserver.fqdn}' => "Isabelroses's Mail Server",
            'ssl://imap.gmail.com:993' => 'Google Mail',
          );
          $config['username_domain'] = array(
            '${config.mailserver.fqdn}' => '${domain}',
            'mail.gmail.com' => 'gmail.com',
          );
          $config['x_frame_options'] = false;
          # starttls needed for authentication, so the fqdn required to match
          # the certificate
          $config['smtp_host'] = "ssl://${config.mailserver.fqdn}";
          $config['smtp_user'] = "%u";
          $config['smtp_pass'] = "%p";
        '';
      };

      postfix = {
        dnsBlacklists = [
          "all.s5h.net"
          "b.barracudacentral.org"
          "bl.spamcop.net"
          "blacklist.woody.ch"
        ];
        dnsBlacklistOverrides = ''
          ${domain} OK
          ${config.mailserver.fqdn} OK
          127.0.0.0/8 OK
          10.0.0.0/8 OK
          192.168.0.0/16 OK
        '';

        config = {
          smtp_helo_name = config.mailserver.fqdn;
        };
      };

      phpfpm.pools.roundcube.settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
      };

      nginx.virtualHosts = {
        ${config.mailserver.fqdn} = template.ssl;
        "webmail.${domain}" = template.ssl;
        # "rspamd.${domain}" = mkIf (cfg.mailserver.enable && cfg.mailserver.rspamd-web.enable) {
        #   forceSSL = true;
        #   enableACME = true;
        #   basicAuthFile = config.sops.secrets.rspamd-web.path;
        #   locations."/".proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
        # };
      };
    };
  };
}