{
  network = {
    description = "FnF network";
    enableRollback = true;
  };

  node = import ./configuration-node.nix;
  relay = import ./configuration-relay.nix;
}
