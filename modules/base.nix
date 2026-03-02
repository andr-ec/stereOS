# modules/base.nix
#
# Core stereOS system configuration.
# Provides: SSH, nix settings, essential packages, hardening.
#
# VM-specific config (QEMU guest profile, filesystem, os-release branding)
# is guarded by stereos.vm.enable — disable when importing into an existing
# NixOS system.
#
# Boot configuration lives in boot.nix.

{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkMerge [
    # -- Always-on config (safe for any NixOS system) --------------------------
    {
      # -- SSH ----------------------------------------------------------------
      services.openssh = {
        enable = lib.mkDefault true;
        settings = {
          PasswordAuthentication = lib.mkDefault false;
          PermitRootLogin = lib.mkDefault "no";
          KbdInteractiveAuthentication = lib.mkDefault false;
        };
      };

      # -- Nix settings -------------------------------------------------------
      nix.settings = {
        experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
        auto-optimise-store = lib.mkDefault true;

        # CRITICAL: Only root and wheel can talk to the Nix daemon.
        # The 'agent' user is explicitly excluded — this is the primary
        # mechanism that prevents the AI agent from using nix tooling.
        allowed-users = [ "root" "@wheel" ];
        trusted-users = lib.mkDefault [ "root" ];
      };

      # -- System packages ----------------------------------------------------
      environment.systemPackages = with pkgs; [
        git
        vim
        curl
        jq
        ripgrep
        htop
        tmux
        tree
        file
        unzip
        ghostty.terminfo  # xterm-ghostty terminfo entry
        gvisor            # runsc: gVisor sandbox runtime for sandboxed agents
      ];

      # -- Locale and timezone ------------------------------------------------
      time.timeZone = lib.mkDefault "UTC";
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

      # -- Firewall -----------------------------------------------------------
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [ 22 ];  # SSH
      };

      # -- Kernel hardening ---------------------------------------------------
      boot.kernel.sysctl = {
        # Restrict process tracing (blocks ptrace-based attacks)
        "kernel.yama.ptrace_scope" = lib.mkDefault 2;

        # Hide kernel pointers from non-root
        "kernel.kptr_restrict" = lib.mkDefault 2;

        # Restrict dmesg to root
        "kernel.dmesg_restrict" = lib.mkDefault 1;

        # Disable core dumps via pipe
        "kernel.core_pattern" = lib.mkDefault "|/bin/false";

        # Network hardening
        "net.ipv4.conf.all.accept_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.default.accept_redirects" = lib.mkDefault 0;
        "net.ipv6.conf.all.accept_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.all.send_redirects" = lib.mkDefault 0;
      };

      # -- Ensure /tmp is tmpfs (ephemeral, never written to disk) ------------
      boot.tmp.useTmpfs = lib.mkDefault true;
    }

    # -- VM-only config (dedicated stereOS VM) ---------------------------------
    (lib.mkIf config.stereos.vm.enable {
      # QEMU guest agent and virtio support (equivalent to qemu-guest.nix profile).
      # Cannot use conditional imports (infinite recursion), so inline the config.
      services.qemuGuest.enable = lib.mkDefault true;

      # NixOS system version to track
      system.stateVersion = "24.11";

      # Override /etc/os-release so tools like hostnamectl show stereOS
      environment.etc."os-release".text = lib.mkForce ''
        NAME="stereOS"
        ID=stereos
        ID_LIKE=nixos
        VERSION="${config.system.nixos.version}"
        VERSION_ID="${config.system.nixos.version}"
        PRETTY_NAME="stereOS (${config.networking.hostName})"
        HOME_URL="https://github.com/paper-compute-co"
      '';

      # stereOS ASCII art MOTD
      users.motd = ''
  ______   ______  ______   ______   ______   ______   ______
 /\  ___\ /\__  _\/\  ___\ /\  == \ /\  ___\ /\  __ \ /\  ___\
 \ \___  \\/_/\ \/\ \  __\ \ \  __< \ \  __\ \ \ \/\ \\ \___  \
  \/\_____\  \ \_\ \ \_____\\ \_\ \_\\ \_____\\ \_____\\/\_____\
   \/_____/   \/_/  \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/

    Mixtape: ${config.networking.hostName}

      '';

      # Filesystem
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
        autoResize = true;
      };

      # stereOS images are built without baked-in SSH keys or passwords.
      users.allowNoPasswordLogin = true;
    })
  ];
}
