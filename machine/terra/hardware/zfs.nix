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
        bootDevices = ["nvme-eui.002538d51100a6ad"];
        immutable = false;
        availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
        removableEfi = false;
        kernelParams = [];
      };
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    networking.hostId = "8ffb526d";
  };
  meta = {};
}
