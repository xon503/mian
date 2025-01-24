{
  garden.system = {
    mainUser = "isabel";

    users.isabel = {
      programs = {
        cli = {
          enable = false;
          modernShell.enable = false;
        };

        tui.enable = false;
        gui.enable = false;

        git.signingKey = "7F2F6BD6997FCDF7";
      };
    };
  };
}
