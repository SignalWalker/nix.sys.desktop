{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  config = {
    boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      # grub.devices = [
      #   "/dev/disk/by-id/wwn-0x5001b44c835b39c0"
      # ];
    };

    system.copySystemConfiguration = true;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/4dbbdac2-37a3-4578-a27b-fa43e2d483a3";
      fsType = "btrfs";
      options = ["subvol=root" "compress=zstd" "autodefrag"];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/4dbbdac2-37a3-4578-a27b-fa43e2d483a3";
      fsType = "btrfs";
      options = ["subvol=home" "compress=zstd" "autodefrag"];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/4dbbdac2-37a3-4578-a27b-fa43e2d483a3";
      fsType = "btrfs";
      options = ["subvol=nix" "compress=zstd" "noatime" "autodefrag"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C3D6-5EBD";
      fsType = "vfat";
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/526a9c71-bde5-41da-a0bd-77a3d2270d73";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    services.thermald.enable = true;

    powerManagement = {
      enable = true;
    };

    networking.hostId = "007f0200";

    hardware.bluetooth = {
      enable = true;
    };
  };
  meta = {};
}
