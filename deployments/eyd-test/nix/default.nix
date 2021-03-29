{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
, sourcesOverride ? {}
}:
let
  sources = import ./sources.nix { inherit pkgs; }
    // sourcesOverride;

  nixpkgs = sources.nixpkgs;

  overlays = [];

  pkgs = import nixpkgs {
    inherit system crossSystem overlays;
    config = config;
  };

in pkgs
