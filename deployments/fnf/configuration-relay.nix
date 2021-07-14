{ config, pkgs, nodes, ... }:

let
  sources = import ../../nix/sources.nix;

  cardanoNodeProject = import sources.cardano-node {};
in

{
  networking.firewall.allowedTCPPorts = [ 22
                                          3000  # grafana
                                          3001  # cardano
                                          12789 # cardano-metrics
                                          9090  # prometheus
                                        ];

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
    environment = "shelley_testnet";
    hostAddr = "0.0.0.0";
    topology =  builtins.toFile "topology.json" (builtins.toJSON {
      Producers = [
        {
          addr = "relays-new.shelley-testnet.dev.cardano.org";
          port = 3001;
          valency = 1;
        }
        {
          addr = nodes.node.config.networking.privateIPv4;
          port = 3001;
          valency = 1;
        }
      ];
    });
    nodeConfig = config.services.cardano-node.environments.shelley_testnet.nodeConfig // {
      hasPrometheus = [ nodes.relay.config.networking.privateIPv4 12789 ];
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
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "cardano-node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ "${nodes.node.config.networking.privateIPv4}:12789" ];
            labels = { alias = "block-producer"; };
          }
          {
            targets = [ "${nodes.relay.config.networking.privateIPv4}:12789" ];
            labels = { alias = "relay"; };
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
  };
}
