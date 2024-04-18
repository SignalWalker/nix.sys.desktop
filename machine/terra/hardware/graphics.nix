{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    environment.sessionVariables = {
      NVD_LOG = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    environment.variables."EXTRA_SWAY_ARGS" = "--unsupported-gpu";

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      nvidiaPersistenced = false;
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    virtualisation.containers = {
      cdi.dynamic.nvidia.enable = true;
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        vulkan-validation-layers
      ];
    };
  };
  meta = {};
}