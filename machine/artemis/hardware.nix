{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with builtins; let
  std = pkgs.lib;

  use_pstate = !(elem "intel_pstate=disable" config.boot.kernelParams);
in {
  options = with lib; {};
  disabledModules = [];
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ (lib.signal.fs.path.listFilePaths ./hardware);
  config = {
    environment.systemPackages = with pkgs; [
      # intel-gpu-tools
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # handled by nixos-hardware#framework
    # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # boot.kernelPackages = pkgs.linuxPackages_latest;

    hardware.intelgpu = {
      driver = "xe";
      loadInInitrd = true;
    };

    boot.kernelParams = [
      "i915.force_probe=a7a0"
    ];

    # boot.kernelParams = lib.mkIf config.services.auto-cpufreq.enable [
    #   "intel_pstate=disable"
    # ];
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor =
            if use_pstate
            then "powersave"
            else "schedutil";
          energy_performance_preference = "balance";
          turbo = "auto";
        };
        charger = {
          governor =
            if use_pstate
            then "performance"
            else "schedutil";
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

    # nixpkgs.config.packageOverrides = pkgs: {
    #   vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    # };
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [];
    };

    services.xserver.xkb = {
      model = "pc104";
    };

    programs.gamescope.args = [
      "-w 2256"
      "-h 1504"
    ];
  };
  meta = {};
}
