# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  sources = import ../nix/sources.nix;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../nixos/modules/direnv.nix
      ../nixos/modules/yubikey.nix 
      ../nixos/modules/keybase.nix 
      "${sources.home-manager}/nixos"
    ];

  home-manager.users.sam = {...}: {
    imports = [
      ../home/emacs
      ../home/gnupg
      ../home/xmobar
      ../home/xmonad
      ../home/xresources
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;

  networking.hostName = "sam-laptop-nixos"; # Define your hostname.

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

  services.emacs.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    cabal-install
    cabal2nix
    chromium
    cntr
    # dhcpcd
    docker
    dmenu
    emacs
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
    stack
    spotify
    toxiproxy
    tlaplusToolbox
    tree
    unzip
    vim
    wget 
    weechat
    xscreensaver
    zathura
  ]) ++ 
  (with pkgs.haskellPackages; [
    ghcid
    hasktags
    hoogle
    xmobar
  ]);

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
    alias work-vpn-up='sudo systemctl start openvpn-work-vpn.service'
    alias work-vpn-down='sudo systemctl stop openvpn-work-vpn.service'
    alias work-vpn-status='sudo systemctl status openvpn-work-vpn.service; echo ""; echo "/etc/resolv.conf:"; cat /etc/resolv.conf'
    alias ssh-iohk='ssh -F ~/.ssh/iohk.config'
  '';

  # List services that you want to enable:
  services.sshd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  virtualisation.libvirtd.enable = true;
  networking.firewall.checkReversePath = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  #

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    desktopManager.xterm.enable = false;

    xkbOptions="ctrl:nocaps";
    #videoDrivers = ["nvidia"];

    displayManager.defaultSession = "none+xmonad";

    libinput.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.sam = {
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "disk" "networkmanager" "docker" "libvirtd" "dialout"];
    group = "users";
    home = "/home/sam";
    isNormalUser = true;
    uid = 1000;
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "sam" ];

  nix.trustedUsers = ["root" "sam"];
  #nix.sandboxPaths = ["/home/sam/.ssh"];

  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://iohk.cachix.org"
    "https://hydra.iohk.io"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
