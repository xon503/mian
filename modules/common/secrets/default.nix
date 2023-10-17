{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) services;
in {
  imports = [inputs.sops.nixosModules.sops];

  environment.systemPackages = with pkgs; [sops age];

  sops = {
    defaultSopsFile = ./secrets.yaml;

    age.keyFile = "/home/${config.modules.system.mainUser}/.config/sops/age/keys.txt";

    secrets = let
      inherit (config.modules.system) mainUser;
      homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
      sshDir = homeDir + "/.ssh";
    in {
      # server
      cloudflared-hydra = mkIf services.cloudflared.enable {
        owner = "cloudflared";
        group = "cloudflared";
      };

      # mailserver
      rspamd-web = {};
      mailserver-isabel = {};
      mailserver-vaultwarden = {};
      mailserver-database = {};
      mailserver-grafana = {};

      mailserver-grafana-nohash = mkIf services.monitoring.grafana.enable {
        owner = "grafana";
        group = "grafana";
      };

      mailserver-gitea = {};
      mailserver-gitea-nohash = mkIf services.gitea.enable {
        owner = "git";
        group = "git";
      };

      isabelroses-web-env = {};

      # vaultwarden
      vaultwarden-env = {};

      # miniflux
      miniflux-env = mkIf services.miniflux.enable {
        owner = "miniflux";
        group = "miniflux";
      };

      # matrix
      matrix = mkIf services.matrix.enable {
        owner = "matrix-synapse";
        mode = "400";
      };

      docker-hub = {};

      #wakapi
      wakapi = mkIf services.wakapi.enable {
        owner = "wakapi";
        group = "wakapi";
      };

      mongodb-passwd = mkIf services.database.mongodb.enable {
        mode = "400";
      };

      # user
      git-credentials = {
        path = homeDir + "/.git-credentials";
        owner = mainUser;
      };

      # git ssh keys
      gh-key = {
        path = sshDir + "/github";
        owner = mainUser;
      };
      gh-key-pub = {
        path = sshDir + "/github.pub";
        owner = mainUser;
      };
      aur-key = {
        path = sshDir + "/aur";
        owner = mainUser;
      };
      aur-key-pub = {
        path = sshDir + "/aur.pub";
        owner = mainUser;
      };

      # ORACLE vps'
      openvpn-key = {
        path = sshDir + "/openvpn";
        owner = mainUser;
      };
      amity-key = {
        path = sshDir + "/amity";
        owner = mainUser;
      };
      king-key = {
        path = sshDir + "/king";
        owner = mainUser;
      };

      # All nixos machines
      nixos-key = {
        path = sshDir + "/nixos";
        owner = mainUser;
      };
      nixos-key-pub = {
        path = sshDir + "/nixos.pub";
        owner = mainUser;
      };

      # my local servers / clients
      /*
      alpha-key = {
        path = sshDir + "/alpha";
        owner = mainUser;
      };
      alpha-key-pub = {
        path = sshDir + "/alpha.pub";
        owner = mainUser;
      };
      */
    };
  };
}
