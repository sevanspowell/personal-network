{ config, pkgs, lib, ... }:

let
  sources = import ../../../nix/sources.nix;
  homeManagerLib = import "${sources.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      "${sources.home-manager}/nixos"
      ../personal/nixos/modules/yubikey.nix
    ];

  nix.nixPath =
    [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/persist/etc/nixos/personal-network/deployments/eyd-test/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

  hardware.yubikey-gpg = {
    enable = true;
    user = "sam";
    pinentryFlavor = "curses";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # source: https://grahamc.com/blog/erase-your-darlings
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
    zfs rollback -r rpool/safe/home@blank
  '';
  boot.initrd.luks.devices = {
    root = { 
      device = "/dev/sda1";
      preLVM = true;
    };
  };
  swapDevices = [
    { device = "/dev/nixos-vg/swap"; }
  ];

  # source: https://grahamc.com/blog/nixos-on-zfs
  boot.kernelParams = [ "elevator=none" ];

  networking.hostId = "fd7a20bd";
  networking.networkmanager.enable = true;

  environment.systemPackages = (with pkgs;
    [
      emacs
      vim
      rxvt_unicode-with-plugins
    ]) ++ (with pkgs.haskellPackages; [
      xmobar
    ]);

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    # TODO: autoReplication
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        initialHashedPassword = "\$6\$q.f5/ghrb0ei\$NzVIVd0wEfk2gIaoaAtGJrVy4TMgMbSvf.1oC4vlirz70MBquhuI2Pbd5rKmSjGTzrjDOiET/ImXT2WO.DZqf1";
      };

      sam = {
        createHome = true;
        initialHashedPassword = "\$6\$pcbXwn5E\$4mj5qgQHU/U5NP/aojBEYDle5.1pv76Cyd3x2W6IX7Y06QG2BiUbW9AydBIf5JJq/.kgvF2Pr3c/B7Yst4wgT/";
	extraGroups = [ "wheel" "networkmanager" ];
	group = "users";
	uid = 1000;
	home = "/home/sam";
	useDefaultShell = true;
        openssh.authorizedKeys.keys = [ ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/sam - sam users - -"
    "L /home/sam/code - - - - /persist/home/sam/code"
    "L /home/sam/.nix-profile - - - - /nix/var/nix/profiles/per-user/sam/profile"
    "d /home/sam/.nix-defexpr - sam users - -"
    "L /home/sam/.nix-defexpr/channels - - - - /nix/var/nix/profiles/per-user/sam/channels"
  ];

  home-manager.users.sam = {...}: {
    imports = [
      ../personal/home/emacs
      ../personal/home/xmobar
      ../personal/home/xmonad
      ../personal/home/xresources
    ];
    home.file.".gitconfig".text = import ./.gitconfig.nix {};
  };

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.xterm.enable = false;
    xkbOptions = "ctrl:nocaps";
    videoDrivers = ["nvidia"];
   
    displayManager.defaultSession = "none+xmonad";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
