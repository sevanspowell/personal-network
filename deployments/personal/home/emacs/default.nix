{ config, pkgs, ... }:

let
  emacsOverlay = import (builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;});
  emacsLocal = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.readFile ./init.el;
    extraEmacsPackages = epkgs: [ epkgs.emacs-libvterm epkgs.emacsql-sqlite ];
  };
in

{
  nixpkgs.overlays = [ emacsOverlay ];

  home.packages = [
    pkgs.sqlite
  ];

  programs.emacs = {
    enable = true;
    package = emacsLocal.overrideAttrs (oldAttrs: {
      buildCommand = oldAttrs.buildCommand + ''
      ln -s $emacs/share/emacs $out/share/emacs
      '';
    });
  };

  home.file.".emacs.d/init.el".source           = ./init.el;
  home.file.".emacs.d/configuration.org".source = ./configuration.org;
}
