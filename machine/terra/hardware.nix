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

    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          energy_performance_preference = "balance_power";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          energy_performance_preference = "performance";
          turbo = "auto";
        };
      };
    };

    services.tlp.enable = false;
    services.thermald.enable = false;

    hardware.bluetooth = {
      enable = true;
    };

    boot.supportedFilesystems = ["ntfs"];

    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    boot.loader.grub.useOSProber = true;

    # VFIO (doesn't work on terra atm)
    # boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
    # boot.kernelParams = [
    #   "intel_iommu=on"
    #   "iommu=pt"
    # ];
  };
  meta = {};
}
