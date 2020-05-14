{ pkgs ? import ./nix {} }:

let
  sources = import ./nix/sources.nix;

  cardanoNodeProject = import sources.cardano-node {};
in

pkgs.mkShell {
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  buildInputs = with pkgs; [
    direnv
    nixops
    nix
    niv
    cardanoNodeProject.cardano-cli
  ];

  NIX_PATH = "nixpkgs=${pkgs.path}";
}
