{ config, pkgs, ... }:

{
  home.file.".gnupg/gpg.conf".source       = ./gpg.conf;
  home.file.".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  home.file.".gnupg/scdaemon.conf".source  = ./scdaemon.conf;
}
