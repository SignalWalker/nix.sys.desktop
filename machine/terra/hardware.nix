{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with builtins;
let
  std = pkgs.lib;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ lib.listFilePaths ./hardware;
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # fileSystems."/windows" = {
    #   device = "/dev/disk/by-uuid/B050B49B50B46A2C";
    #   fsType = "ntfs";
    #   mountPoint = "/windows";
    #   options = [
    #     "uid=ash"
    #     "gid=users"
    #     "umask=227"
    #     "ro"
    #   ];
    # };

    programs.auto-cpufreq = {
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

    boot.supportedFilesystems = [
      "bcachefs"
      "ntfs"
    ];

    # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    boot.loader.grub.useOSProber = true;

    # HACK :: I think this is fine since we have a ton of swap?
    boot.tmp.tmpfsSize = "100%";
    # TODO :: runSize? devSize?

    # VFIO (doesn't work on terra atm)
    # boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
    # boot.kernelParams = [
    #   "intel_iommu=on"
    #   "iommu=pt"
    # ];
  };
  meta = { };
}