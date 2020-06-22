{ config, pkgs, ... }:

let
  emacsOverlay = import (builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;});
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.readFile ./init.el;
    extraEmacsPackages = epkgs: [ epkgs.emacs-libvterm ];
  };
in

{
  nixpkgs.overlays = [ emacsOverlay ];

  programs.emacs = {
    enable = true;
    package = emacs.overrideAttrs (oldAttrs: {
      buildCommand = oldAttrs.buildCommand + ''
      ln -s $emacs/share/emacs $out/share/emacs
      '';
    });
  };

  home.file.".emacs.d/init.el".source           = ./init.el;
  home.file.".emacs.d/configuration.org".source = ./configuration.org;
}
