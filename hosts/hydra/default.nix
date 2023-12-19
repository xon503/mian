_: {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "laptop";
        cpu = "intel";
        gpu = null;
        monitors = ["eDP-1"];
        hasTPM = true;
        hasBluetooth = true;
        hasSound = true;
      };

      system = {
        mainUser = "isabel";

        boot = {
          plymouth.enable = false;
          loader = "systemd-boot";
          secureBoot = false;
          enableKernelTweaks = true;
          initrd.enableTweaks = true;
          loadRecommendedModules = true;
          tmpOnTmpfs = true;
        };

        fs = ["btrfs" "vfat"];
        video.enable = true;
        sound.enable = true;
        bluetooth.enable = true;
        printing.enable = false;
        yubikeySupport.enable = true;

        # autoLogin = true;

        encryption = {
          enable = false;
          device = "crypt";
        };

        security = {
          fixWebcam = false;
          auditd.enable = true;
        };

        networking = {
          optimizeTcp = true;
          nftables.enable = true;

          wirelessBackend = "iwd";

          tailscale = {
            enable = true;
            isClient = true;
          };
        };

        virtualization = {
          enable = true;
          docker.enable = true;
          qemu.enable = false;
          podman.enable = false;
          distrobox.enable = false;
        };
      };
      usrEnv = {
        isWayland = true;
        desktop = "Hyprland";
        useHomeManager = true;
      };

      programs = {
        git.signingKey = "0xAE22E70709810C07";

        cli = {
          enable = true;
          modernShell.enable = true;
        };
        tui.enable = true;
        gui.enable = true;

        zathura.enable = true;

        # gaming = {
        #   enable = true;
        #   steam.enable = true;
        # };

        defaults = {
          bar = "ags";
        };
      };

      services = {
        smb = {
          enable = false;
          recive = {
            media = false;
            general = false;
          };
        };
        vscode-server.enable = true;
        cloudflared.enable = false;
        jellyfin.enable = false;
      };
    };

    boot = {
      kernelParams = [
        "nohibernate"
        "i915.enable_fbc=1"
        "i915.enable_psr=2"
      ];
    };

    console.earlySetup = true;
  };
}
