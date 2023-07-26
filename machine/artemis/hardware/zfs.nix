{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./zfs;
  config = {
    zfs-root = {
      boot = {
        devNodes = "/dev/disk/by-id/";
        bootDevices = [  "nvme-WDC_PC_SN530_SDBPNPZ-1T00-1002_20309U447208" ];
        immutable = false;
        availableKernelModules = [  "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
        removableEfi = false;
        kernelParams = [ ];
      };
    };

    networking.hostId = "d8aabc08";
  };
  meta = {};
}
