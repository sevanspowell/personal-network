{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
}:
let
  sourcePaths = import ./sources.nix;

  overlays = [
    (final: prev: {
      nixops = (import "${sourcePaths.nixops}/release.nix" {
       nixpkgs = "${sourcePaths.nixpkgs}";
       p = (p:
         let
           nixopsAWS = p.callPackage "${sourcePaths.nixops-aws}/release.nix" {};
         in [ nixopsAWS ]);
      }).build.${system};

      sources = sourcePaths;
    })
  ];

  pkgs = import sourcePaths.nixpkgs {
    inherit config system crossSystem overlays;
  };

in pkgs
