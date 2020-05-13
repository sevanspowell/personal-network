{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
}:
let
  sourcePaths = import ./sources.nix;

  pkgs = import sourcePaths.nixpkgs {
    inherit config system crossSystem;
  };

in pkgs
