# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  sources = import ../nix/sources.nix;
  # cardano-cli = (import sources.cardano-node {}).cardano-cli;

  zsa-udev-rules = pkgs.callPackage ./zsa-udev-rules.nix {};
in

{
  boot.initrd.luks.devices = { 
    nixos-enc = { device = "/dev/disk/by-uuid/8cbcb189-ce25-460b-b980-d67ed7e7cc4c"; preLVM = true; };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../nixos/modules/direnv.nix
      # ../nixos/modules/keybase.nix
      # ../nixos/modules/yubikey.nix
      # ../../../../network/modules/yubikey-gpg/persist.nix
      ../../../../network/modules/yubikey-gpg
      "${sources.home-manager}/nixos"
      # "${sources.cardano-node}/nix/nixos"
      # "${sources.cardano-db-sync}/nix/nixos"
    ];


  home-manager.users.sam = {...}: {
    imports = [
      ../home/emacs
      ../home/xmobar
      ../home/xmonad
      ../home/xresources
    ];
  };

  hardware.yubikey-gpg = {
    enable = true;

    users = {
      sam.pinentryFlavor = "gnome3";
      root.pinentryFlavor = "curses";
    };
  };

  # hardware.yubikey-gpg = {
  #   enable = true;
  #   pinentryFlavor = "gnome3";
  #   user = "sam";
  # };

  services.trezord.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "orchid"; # Define your hostname.

  # # hardware.keyboard.zsa.enable = true;
  # services.udev.packages = [ zsa-udev-rules ];
  # users.groups.plugdev = {};

  # # Configure network proxy if necessary
  # # networking.proxy.default = "http://user:password@proxy:port/";
  # # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Australia/Perth";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    # cardano-cli
    cabal-install
    cabal2nix
    chromium
    cntr
    # dhcpcd
    docker
    dmenu
    firefox
    feh
    ghc
    go-jira
    git
    gnumake
    ledger
    libreoffice
    mitscheme
    mosh
    nixops
    openssl
    openvpn
    pandoc
    pavucontrol
    patchutils
    pass
    ripgrep
    rofi
    rxvt_unicode-with-plugins
    silver-searcher
    spotify
    toxiproxy
    tlaplusToolbox
    tree
    unzip
    vim
    wally-cli
    wget 
    weechat
    wireguard
    xscreensaver
    zathura
  ]) ++ 
  (with pkgs.haskellPackages; [
    ghcid
    hasktags
    hoogle
    xmobar
  ]) ++ [];

  fonts.fonts = with pkgs; [
    fira-code
    iosevka
    hack-font
    hasklig
    meslo-lg
    source-code-pro
  ];

  environment.interactiveShellInit = ''
    alias dropbox="docker exec -it dropbox dropbox"
    alias dropbox-start="docker run -d --restart=always --name=dropbox \
      -v /home/sam/Dropbox:/dbox/Dropbox \
      -v /home/sam/.dropbox:/dbox/.dropbox \
      -e DBOX_UID=1000 -e DBOX_GID=100 janeczku/dropbox"
    alias ssh-iohk='ssh -F ~/.ssh/iohk.config'
  '';

  # # List services that you want to enable:
  services.sshd.enable = true;

  # # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # # services.cardano-node = {
  # #     environment = "testnet";
  # #     enable = true;
  # #     systemdSocketActivation = true;
  # # };
  # # services.cardano-db-sync = {
  # #   cluster = "testnet";
  # #   enable = true;
  # #   socketPath = "/run/cardano-node/node.socket";
  # #   user = "cardano-node";
  # #   extended = true;
  # #   postgres = {
  # #     database = "cexplorer";
  # #   };
  # # };
  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    settings = {
      max_connections = 200;
      shared_buffers = "2GB";
      effective_cache_size = "6GB";
      maintenance_work_mem = "512MB";
      checkpoint_completion_target = 0.7;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1;
      effective_io_concurrency = 200;
      work_mem = "10485kB";
      min_wal_size = "1GB";
      max_wal_size = "2GB";
    };
    identMap = ''
      explorer-users /root cardano-node
      explorer-users /postgres postgres
      explorer-users /sam cardano-node
      explorer-users /cardano-node cardano-node
    '';
    authentication = ''
      local all all ident map=explorer-users
      local all all trust
    '';
    ensureDatabases = [
      "explorer_python_api"
      "cexplorer"
      "hdb_catalog"
    ];
    ensureUsers = [
      {
        name = "cardano-node";
        ensurePermissions = {
          "DATABASE explorer_python_api" = "ALL PRIVILEGES";
          "DATABASE cexplorer" = "ALL PRIVILEGES";
          "DATABASE hdb_catalog" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
    initialScript = pkgs.writeText "init.sql" ''
      CREATE USER sam WITH SUPERUSER;
      CREATE USER root WITH SUPERUSER;
      CREATE DATABASE sam WITH OWNER sam;
    '';
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  virtualisation.libvirtd.enable = true;
  networking.firewall.checkReversePath = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable wifi
  # networking.networkmanager.enable = true;
  # networking.wireless.enable = true;
  # networking.wireless.networks = {
  #   "Aussie Broadband 4089" = {
  #     pskRaw = "7ffdd238802cf375e7dd250e7137b4495d790cc2f14db762791eaf985a03af8f";
  #   };
  #   iiNetB25B7F = {
  #     pskRaw = "7d7d98bf565e4fe7ff00a0f3188b172cb05b7f9c300ac79f22722b6e94a6ae49";
  #   };
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.xterm.enable = false;
    xkbOptions="ctrl:nocaps";
    videoDrivers = ["nvidia"];

    displayManager.defaultSession = "none+xmonad";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    #windowManager.windowmaker.enable = true;
  };

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # # Enable the KDE Desktop Environment.
  # # services.xserver.displayManager.sddm.enable = true;
  # # services.xserver.desktopManager.plasma5.enable = true;
  # services.openvpn.servers = {
  #   work-vpn = {
  #     config = "config /home/sam/vpn/work-vpn/config.ovpn";
  #     autoStart = false;
  #     updateResolvConf = true;
  #   };
  # };

  # services.lorri.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.sam = {
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "disk" "networkmanager" "docker" "libvirtd" "dialout" "plugdev" ];
    group = "users";
    home = "/home/sam";
    isNormalUser = true;
    uid = 1000;
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "sam" ];

  # nix.trustedUsers = ["root" "sam"];
  # nix.sandboxPaths = ["/home/sam/.ssh"];
  # nix.extraOptions = ''
  #   # plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins/libnix-extra-builtins.so
  #   experimental-features = nix-command flakes ca-references
  # '';

  nix.binaryCaches = [
    "https://sevanspowell-personal.cachix.org"
    "https://cache.nixos.org"
    "https://iohk.cachix.org"
    "https://hydra.iohk.io"
    # "https://mantis-ops.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "sevanspowell-personal.cachix.org-1:VOY8b19A+HGl1xUof+ucLFTDRCYBhjv+q94rxt5t5Bk="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    # "mantis-ops.cachix.org-1:SornDcX8/9rFrpTjU+mAAb26sF8mUpnxgXNjmKGcglQ="
  ];

  nixpkgs.config.allowUnfree = true;

  # # This value determines the NixOS release with which your system is to be
  # # compatible, in order to avoid breaking some software such as database
  # # servers. You should change this only after NixOS release notes say you
  # # should.
  system.stateVersion = "18.09"; # Did you read the comment?

  # services.logind.extraConfig = ''
  #   RuntimeDirectorySize=8G
  # '';

  # # networking.nat.internalInterfaces = "wg0";
  # networking.firewall = {
  #   allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];
  # };

  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = [ "10.0.0.1/24" ];
  #     listenPort = 51820;

  #     privateKeyFile = "/etc/wg0/private";

  #     peers = [
  #       { # EYD VM
  #         publicKey = "7X0oyS0bWJDxbXpo1PqA4o5GPYJiKDxmLb9AsZriREU=";
  #         allowedIPs = [ "10.0.0.2/32" ];
  #         persistentKeepalive = 25;
  #         endpoint = "192.168.56.224:51820";
  #       }
  #     ];
  #   };
  # };
}
