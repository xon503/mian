{ inputs', ... }:
{
  garden.system = {
    mainUser = "robin";

    users.robin = {
      programs = {
        cli = {
          enable = true;
          modernShell.enable = true;
        };
        tui.enable = true;
        gui.enable = false;

        fish.enable = true;

        neovim.package = inputs'.ivy.packages.default;
      };
    };
  };
}
