{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    zfs-root = {
      boot = {
        enable = true;
        devNodes = "/dev/disk/by-id/";
        bootDevices = [ "nvme-eui.002538d51100a6ad" ];
        immutable = false;
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        removableEfi = true;
        kernelParams = [ ];
        sshUnlock = {
          enable = false;
          authorizedKeys = config.users.users."root".openssh.authorizedKeys.keys;
        };
      };
    };

    networking.hostId = "8ffb526d";

    boot.zfs = {
      extraPools = [ "elysium" ];
    };
  };
  meta = { };
}

