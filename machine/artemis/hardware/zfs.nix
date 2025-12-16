{
  config,
  lib,
  ...
}:
let
  zfs-root = config.zfs-root;
in
{
  config = {
    zfs-root = {
      boot = {
        enable = false;
        devNodes = "/dev/disk/by-id/";
        bootDevices = [ "nvme-WDC_PC_SN530_SDBPNPZ-1T00-1002_20309U447208" ];
        immutable = false;
        availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        removableEfi = false;
        kernelParams = [ ];
      };
    };

    networking.hostId = lib.mkIf zfs-root.boot.enable "d8aabc08";
  };
  meta = { };
}
