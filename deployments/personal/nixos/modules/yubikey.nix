{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.hardware.yubikey-gpg;
in

{
  
  options.hardware.yubikey-gpg = {
    enable = mkEnableOption "Enables yubikey GPG auth/enc/sign for a user.";

    pinentryFlavor = mkOption {
      type = types.nullOr (types.enum pkgs.pinentry.flavors);
      example = "gnome3";
      description = ''
        Which pinentry interface to use. If not null, the path to the
        pinentry binary will be passed to gpg-agent via commandline and
        thus overrides the pinentry option in gpg-agent.conf in the user's
        home directory.
      '';
    };

    user = mkOption {
      type = lib.types.str;
      description = ''
        User to enable yubikey services for.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        inherit (cfg) pinentryFlavor;
      };
    };
  
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  
    services.udev.extraRules = let
      dependencies = with pkgs; [ coreutils gnupg gawk gnugrep ];
      clearYubikey = pkgs.writeScript "clear-yubikey" ''
        #!${pkgs.stdenv.shell}
        export PATH=${pkgs.lib.makeBinPath dependencies};
        keygrips=$(
          gpg-connect-agent 'keyinfo --list' /bye 2>/dev/null \
            | grep -v OK \
            | awk '{if ($4 == "T") { print $3 ".key" }}')
        for f in $keygrips; do
          rm -v ~/.gnupg/private-keys-v1.d/$f
        done
        gpg --card-status 2>/dev/null 1>/dev/null || true
      '';
      clearYubikeyUser = pkgs.writeScript "clear-yubikey-user" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.sudo}/bin/sudo -u ${cfg.user} ${clearYubikey}
      '';
    in ''
      ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", RUN+="${clearYubikeyUser}"
    '';
  
    environment.systemPackages = with pkgs; [
      gnupg
      pkgs.pinentry."${cfg.pinentryFlavor}"
      paperkey
      yubioath-desktop
      yubikey-manager
      ccid
      gpgme.dev
    ];
  
    services.dbus.enable = true;
  
    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
    '';

    home-manager.users."${cfg.user}" = {...}: {
      home.file.".gnupg/gpg.conf".text       = import ./yubikey/gpg.conf.nix {};
      home.file.".gnupg/gpg-agent.conf".text = import ./yubikey/gpg-agent.conf.nix { inherit pkgs; inherit (cfg) pinentryFlavor; };
      home.file.".gnupg/scdaemon.conf".text  = import ./yubikey/scdaemon.conf.nix {};
    };
  };
}
