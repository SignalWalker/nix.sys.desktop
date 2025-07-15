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

  use_pstate = !(elem "intel_pstate=disable" config.boot.kernelParams);
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ (lib.listFilePaths ./hardware);
  config = {
    # warnings = [
    #   "force-enabling hardware.intelgpu.loadInInitrd"
    # ];

    hardware.intelgpu = {
      driver = "xe";
      # loadInInitrd = lib.mkForce true;
    };

    environment.systemPackages = with pkgs; [
      # intel-gpu-tools
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    system.linuxKernel.filter = name: kp: lib.versionAtLeast kp.kernel.version "6.8";

    # NOTE :: cpu microcode updates handled by nixos-hardware#framework

    boot.kernelParams = [
      # intel graphics (a7a0 not officially supported by xe as of 2024-07-03)
      # "i915.force_probe='!a7a0'"
      # "xe.force_probe='a7a0'"
    ];

    # 2 al pastor, 2 pollo asada tacos

    programs.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = if use_pstate then "powersave" else "schedutil";
          energy_performance_preference = "balance_power";
          turbo = "auto";
        };
        charger = {
          governor = if use_pstate then "performance" else "schedutil";
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
      extraRemotes = [ "lvfs-testing" ];
      uefiCapsuleSettings = {
        "DisableCapsuleUpdateOnDisk" = true;
      };
    };

    hardware.bluetooth = {
      enable = true;
    };

    # nixpkgs.config.packageOverrides = pkgs: {
    #   vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    # };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ ];
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