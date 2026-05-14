{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config = {
    environment.variables = {
      # LIBMOUNT_DEBUG = "all";
    };

    environment.systemPackages = [
      inputs.fw-ectool.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    stylix.targets.grub.enable = false;

    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        device = "nodev"; # = ["/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b444a466e9126"];
        efiInstallAsRemovable = false;
        theme = "${inputs.grub-theme-yorha}/yorha-2256x1504";
      };
    };

    users.mutableUsers = lib.mkForce false;
    users.users.ash.hashedPasswordFile = "/persist/ash-password";
  };
  meta = { };
}
