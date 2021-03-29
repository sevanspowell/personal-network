{ config ? {}
, sourcesOverride ? {}
, pkgs ? import ./nix { inherit config sourcesOverride; }
}:

pkgs.mkShell {

  buildInputs = [ pkgs.nixops ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.path}"
  '';

}
