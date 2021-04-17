{
  network = {
    description = "Erase your darlings test";
    enableRollback = true;
  };

  machine = import ./configuration.nix;
}
