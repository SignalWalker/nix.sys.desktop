{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    environment.variables = lib.mkIf nvidiaEnabled {
      EXTRA_SWAY_ARGS = "--unsupported-gpu";
      WLR_NO_HARDWARE_CURSORS = toString 1;
    };

    hardware.nvidia = lib.mkIf nvidiaEnabled {
      modesetting.enable = true;
      open = false; # causes issues with sway
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      nvidiaPersistenced = false;
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    # virtualisation.containers = {
    #   cdi.dynamic.nvidia.enable = nvidiaEnabled;
    # };

    hardware.nvidia-container-toolkit = {
      enable = nvidiaEnabled;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-validation-layers
      ];
    };

    boot = lib.mkIf (!nvidiaEnabled) {
      kernelModules = [
        "nouveau"
      ];
      kernelParams = [
        "nouveau.config=NvGspRM=1"
        "nouveau.debug=info,VBIOS=info,gsp=debug"
        # "module_blacklist=i915" # fixes black screen issue?
        # "drm.debug=14"
        # "log_buf_len=16M"
      ];
    };
  };
  meta = {};
}
