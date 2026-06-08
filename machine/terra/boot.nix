{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = [ ];
  config = {

    # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    boot = {
      # HACK :: I think this is fine since we have a ton of swap?
      tmp.tmpfsSize = "100%";
      # TODO :: runSize? devSize?

      loader.grub = {
        useOSProber = true;
        extraConfig = ''
          set timeout=6
        '';
      };

      supportedFilesystems = [
        "ntfs"
      ];
    };

    # VFIO (doesn't work on terra atm)
    # boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
    # boot.kernelParams = [
    #   "intel_iommu=on"
    #   "iommu=pt"
    # ];
  };
  meta = { };
}
