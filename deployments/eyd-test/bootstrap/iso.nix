{ config, pkgs, ... }:
let
  install-script = pkgs.callPackage ./install.nix {};
in
  {
    imports = [
      <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ];
  
    hardware.enableAllFirmware = true;
    nixpkgs.config.allowUnfree = true;
  
    environment.systemPackages = with pkgs; [
      install-script
      wget
      vim
      git
      tmux
      gparted
      nix-prefetch-scripts
    ];
  }
