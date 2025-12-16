{
  config,
  lib,
  modulesPath,
  ...
}:
let
  inherit (builtins) elem;
  use_pstate = !(elem "intel_pstate=disable" config.boot.kernelParams);
in
{
  options = { };
  disabledModules = [ ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ]
  ++ (lib.listFilePaths ./hardware);
  config = {
    # warnings = [
    #   "force-enabling hardware.intelgpu.loadInInitrd"
    # ];

    musnix = {
      soundcardPciId = "00:1f.3";
    };

    hardware.intelgpu = {
      driver = "xe";
      # loadInInitrd = lib.mkForce true;
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    system.linuxKernel.filter = name: kp: lib.versionAtLeast kp.kernel.version "6.8";

    # NOTE :: cpu microcode updates handled by nixos-hardware#framework

    boot.kernelParams = [
      # intel graphics (a7a0 not officially supported by xe as of 2024-07-03)
      # "i915.force_probe='!a7a0'"
      # "xe.force_probe='a7a0'"
      "intel_pstate=disable" # auto-cpufreq recommends disabling this
    ];

    # services.tuned = {
    #   enable = true;
    # };

    programs.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = if use_pstate then "powersave" else "schedutil";
          energy_performance_preference = "balance_power";
          energy_perf_bias = "balance_power";
          turbo = "auto";
          scaling_max_freq = 2201000;
        };
        charger = {
          governor = if use_pstate then "performance" else "schedutil";
          energy_performance_preference = "balance_performance";
          energy_perf_bias = "balance_performance";
          turbo = "auto";
          scaling_min_freq = 1000000;
          scaling_max_freq = 2201000;
        };
      };
    };

    services.thermald = {
      enable = true; # recommended for use alongside auto-cpufreq as of 2025-10-18 https://github.com/AdnanHodzic/auto-cpufreq#why-do-i-need-auto-cpufreq
    };

    services.tlp.enable = false;

    powerManagement = {
      enable = true;
    };

    services.fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
      uefiCapsuleSettings = {
        "DisableCapsuleUpdateOnDisk" = true;
      };
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    # nixpkgs.config.packageOverrides = pkgs: {
    #   vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    # };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.xkb = {
      model = "pc104";
    };

    programs.gamescope.args = [
      "-w 2256"
      "-h 1504"
    ];
  };
  meta = { };
}
