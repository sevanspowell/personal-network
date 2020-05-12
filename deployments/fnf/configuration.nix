{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 22 3001 ];
}
