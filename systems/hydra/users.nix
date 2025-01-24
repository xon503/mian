{
  garden.system = {
    mainUser = "isabel";

    users.isabel = {
      programs = {
        cli = {
          enable = true;
          modernShell.enable = true;
        };
        tui.enable = true;
        gui.enable = true;

        git.signingKey = "7AFB9A49656E69F7";
        fish.enable = true;
      };
    };
  };
}
