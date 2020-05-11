{
  network = {
    description = "Test home";
    enableRollback = true;
  };

  test = import ./configuration.nix;
}
