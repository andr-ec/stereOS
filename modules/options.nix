# modules/options.nix
#
# Top-level stereOS options for controlling which module components are active.
# These allow stereOS NixOS modules to be imported into an existing NixOS
# system without conflicting with the host's boot, user, or network config.

{ lib, ... }:

{
  options.stereos = {
    boot.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to configure boot loader, serial console, initrd, and
        boot-time optimizations. Disable when importing stereOS modules
        into an existing NixOS system that has its own boot configuration.
      '';
    };

    vm.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to apply VM-specific configuration (QEMU guest profile,
        filesystem layout, os-release branding). Disable when running
        on an existing NixOS system that is not a dedicated stereOS VM.
      '';
    };

    users.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to create the agent and admin users. When disabled,
        the stereos.agent.basePackages and stereos.agent.extraPackages
        options are still available but no users or groups are created.
      '';
    };
  };
}
