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

  deployment.keys.cardano-kes = {
    text = builtins.readFile /home/sam/cardano/example/node1/kes.skey;
    permissions = "0440";
    group = "cardano-node";
  };
  deployment.keys.cardano-vrf = {
    text = builtins.readFile /home/sam/cardano/example/node1/vrf.skey;
    permissions = "0440";
    group = "cardano-node";
  };
  deployment.keys.cardano-opcert = {
    text = builtins.readFile /home/sam/cardano/example/node1/cert;
    permissions = "0440";
    group = "cardano-node";
  };

  users.users.cardano-node = {
    extraGroups = ["keys"];
  };

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
    kesKey = "/run/keys/cardano-kes";
    vrfKey = "/run/keys/cardano-vrf";
    operationalCertificate = "/run/keys/cardano-opcert";
  };
}
