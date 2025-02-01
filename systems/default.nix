{ self, inputs, ... }:
let
  inherit (self) lib;

  inherit (lib.lists) optionals concatLists;

  gardenModules = ../modules;

  # profiles module, these are sensible defaults for given hardware sets
  # or meta profiles that are used to configure the system based on the requirements of the given machine
  profilesPath = gardenModules + /profiles; # the base directory for the types module

  # hardware profiles
  laptop = profilesPath + /laptop; # for laptop type configurations
  desktop = profilesPath + /desktop; # for desktop type configurations
  server = profilesPath + /server; # for server type configurations
  wsl = profilesPath + /wsl; # for wsl systems
  hybrid = profilesPath + /hybrid; # for systems that are a mix of laptop and server

  # meta profiles
  graphical = profilesPath + /graphical; # for systems that have a graphical interface
  headless = profilesPath + /headless; # for headless systems

  additionalClasses = {
    "image/iso" = "nixos";
    "image/sd-card" = "nixos";
  };

  reclass =
    class:
    (
      additionalClasses
      // {
        "image/iso" = "image";
        "image/sd-card" = "image";
      }
    ).${class} or class;
in
{
  imports = [ inputs.easy-hosts.flakeModule ];

  config.easy-hosts = {
    shared.specialArgs = { inherit lib; };

    inherit additionalClasses;

    perClass = class: {
      modules = concatLists [
        [
          # import the class module, this contains the common configurations between all systems of the same class
          "${self}/modules/${class}/default.nix"
        ]

        (optionals ((reclass class) != "image") [
          # import the home module, which is users for configuring users via home-manager
          "${self}/home/default.nix"

          # import the base module, this contains the common configurations between all systems
          "${self}/modules/base/default.nix"
        ])
      ];
    };

    # This is the list of system configuration
    #
    # the defaults consists of the following:
    #  arch = "x86_64";
    #  class = "nixos";
    #  deployable = false;
    #  modules = [ ];
    #  specialArgs = { };
    hosts = {
      # isabel's hosts
      hydra.modules = [
        hybrid
        graphical
      ];

      tatsumaki = {
        arch = "aarch64";
        class = "darwin";
      };

      amaterasu.modules = [
        desktop
        graphical
      ];

      valkyrie.modules = [
        wsl
        headless
      ];

      minerva = {
        deployable = true;
        modules = [
          server
          headless
        ];
      };

      lilith = {
        class = "image/iso";
        modules = [ headless ];
      };

      hera = {
        class = "image/sd-card";
        arch = "armv6l";
        modules = [ headless ];
      };

      # robin's hosts
      cottage.modules = [
        laptop
        graphical
      ];

      wisp.modules = [
        wsl
        headless
      ];
    };
  };
}
