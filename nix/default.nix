{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
, sourcesOverride ? {}
}:
let
  sourcePaths = import ./sources.nix { inherit pkgs; } // sourcesOverride;

  pkgs = import sourcePaths.nixpkgs {
    inherit config system crossSystem;
  };

in pkgs
