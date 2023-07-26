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
  ] ++ (lib.signal.fs.path.listFilePaths ./hardware);
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    nixpkgs.config.allowBroken = true;

    services.thermald.enable = true;
    powerManagement = {
      enable = true;
    };

    hardware.bluetooth = {
      enable = true;
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
        vaapiIntel
        intel-compute-runtime
        vulkan-validation-layers
      ];
    };
  };
  meta = {};
}
