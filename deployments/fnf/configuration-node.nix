{ config, pkgs, nodes, ... }:

let
  sources = import ../../nix/sources.nix;

  cardanoNodeProject = import sources.cardano-node {};
in

{
  networking.firewall.allowedTCPPorts = [ 22 3001 ];

  environment.systemPackages = [
    cardanoNodeProject.cardano-cli
  ];

  imports = [
    "${sources.cardano-node}/nix/nixos"
  ];

  nix.binaryCaches = [
    "https://hydra.iohk.io"
  ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];

  services.cardano-node = {
    enable = true;
    environment = "ff";
    hostAddr = "0.0.0.0";
    topology =  builtins.toFile "topology.json" (builtins.toJSON {
      Producers = [
        {
          addr = nodes.relay.config.networking.privateIPv4;
          port = 3001;
          valency = 1;
        }
      ];
    });
    nodeConfig = config.services.cardano-node.environments.ff.nodeConfig // {
      hasPrometheus = [ "127.0.0.1" 12798 ];
      setupScribes = [{
        scKind = "JournalSK";
        scName = "cardano";
        scFormat = "ScText";
      }];
      defaultScribes = [
        [
          "JournalSK"
          "cardano"
        ]
      ];
    };
    # kesKey = "/var/run/keys/cardano-kes";
    # vrfKey = "/var/run/keys/cardano-vrf";
    # operationalCertificate = "/var/run/keys/cardano-opcert";
  };
}
