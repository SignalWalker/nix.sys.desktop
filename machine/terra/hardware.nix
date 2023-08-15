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
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ lib.signal.fs.path.listFilePaths ./hardware;
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    services.thermald.enable = true;
    hardware.bluetooth = {
      enable = true;
    };
    boot.supportedFilesystems = ["ntfs"];

    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      nvidiaPersistenced = true;
    };
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        # intel-media-driver
        # vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        # intel-compute-runtime
        nvidia-vaapi-driver
        vulkan-validation-layers
      ];
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      NVD_LOG = "1";
    };

    # VFIO (doesn't work on terra atm)
    # boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
    # boot.kernelParams = [
    #   "intel_iommu=on"
    #   "iommu=pt"
    # ];
  };
  meta = {};
}
