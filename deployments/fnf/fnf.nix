{
  network = {
    description = "FnF network";
    enableRollback = true;
  };

  node = import ./configuration.nix;
}
