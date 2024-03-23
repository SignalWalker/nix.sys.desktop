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
    ++ (lib.signal.fs.path.listFilePaths ./hardware);
  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # handled by nixos-hardware#framework
    # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # boot.kernelPackages = pkgs.linuxPackages_latest;
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

    powerManagement = {
      enable = true;
    };

    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
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
        vaapiVdpau # hardware video acceleration
        intel-compute-runtime
        vulkan-validation-layers
      ];
    };

    services.xserver.xkb = {
      model = "pc104";
    };
  };
  meta = {};
}
