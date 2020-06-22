{ config, pkgs, ... }:

{
  home.file.".gnupg/gpg.conf".source      = ./gpg.conf;
  home.file.".gnupg/scdaemon.conf".source = ./scdaemon.conf;
}
