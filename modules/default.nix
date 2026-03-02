# modules/default.nix
#
# Aggregator — imports all stereOS NixOS sub-modules.
# Consumers (mixtapes, profiles) import this single path to get everything.
#
# For existing NixOS systems, set:
#   stereos.boot.enable = false;  # skip boot/GRUB/initrd config
#   stereos.vm.enable = false;    # skip QEMU guest profile and filesystem
#
# See options.nix for all toggles.

{
  imports = [
    ./options.nix
    ./base.nix
    ./boot.nix
    ./services/stereosd.nix
    ./services/agentd.nix
    ./users/agent.nix
    ./users/admin.nix
  ];
}
