{
  config,
  pkgs,
  lib,
  ...
}: let
  # only the newest nvidia package
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;

  nvidiaPackage =
    if (versionOlder nvBeta.version nvStable.version)
    then nvStable
    else nvBeta;

  inherit (config.modules) device;
  inherit (lib) mkIf mkMerge mkDefault versionOlder;
  env = config.modules.usrEnv;
in {
  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nv") {
    # nvidia drivers kinda are unfree software
    nixpkgs.config.allowUnfree = true;

    services.xserver = mkMerge [
      {
        videoDrivers = ["nvidia"];
      }

      # xorg settings
      (mkIf (!env.isWayland) {
        # disable DPMS
        monitorSection = ''
          Option "DPMS" "false"
        '';

        # disable screen blanking in general
        serverFlagsSection = ''
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
          Option "BlankTime" "0"
        '';
      })
    ];

    boot = {
      # blacklist nouveau module as otherwise it conflicts with nvidia drm
      blacklistedKernelModules = ["nouveau"];
    };

    environment = {
      sessionVariables = mkMerge [
        {
          LIBVA_DRIVER_NAME = "nvidia";
        }

        (mkIf env.isWayland {
          WLR_NO_HARDWARE_CURSORS = "1";
          # GBM_BACKEND = "nvidia-drm"; # breaks firefox apparently
        })

        (mkIf (env.isWayland && device.gpu == "hybrid-nv") {
          #WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
        })
      ];
      systemPackages = with pkgs; [
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        libva
        libva-utils
      ];
    };

    hardware = {
      nvidia = {
        package = mkDefault nvidiaPackage;
        modesetting.enable = mkDefault true;
        prime.offload.enableOffloadCmd = device.gpu == "hybrid-nv";
        powerManagement = {
          enable = mkDefault true;
          finegrained = mkDefault true;
        };

        open = mkDefault true; # use open source drivers by default
        nvidiaSettings = false; # adds nvidia-settings to pkgs, so useless on nixos
        nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
      };

      opengl = {
        extraPackages = with pkgs; [nvidia-vaapi-driver];
        extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver];
      };
    };
  };
}
