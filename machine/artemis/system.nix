{
  lib,
  ...
}:
{
  config = {
    environment.variables = {
      # LIBMOUNT_DEBUG = "all";
    };

    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        device = "nodev"; # = ["/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b444a466e9126"];
        efiInstallAsRemovable = false;
      };
    };

    users.mutableUsers = lib.mkForce false;
    users.users.ash.hashedPasswordFile = "/persist/ash-password";
  };
  meta = { };
}
