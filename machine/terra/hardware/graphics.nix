{
  config,
  pkgs,
  lib,
  ...
}:
let
  # inherit (builtins) toString;
  # nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
  nvidia = config.hardware.nvidia;
in
{
  config = {
    environment.variables = lib.mkIf nvidia.enabled {
      EXTRA_SWAY_ARGS = "--unsupported-gpu";
      WLR_NO_HARDWARE_CURSORS = toString 1;

      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # :eyeroll:
    };

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      nvidiaPersistenced = false;
      branch = "bleeding_edge";
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    # virtualisation.containers = {
    #   cdi.dynamic.nvidia.enable = nvidiaEnabled;
    # };

    hardware.nvidia-container-toolkit = {
      enable = nvidia.enabled;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [
        pkgs.vulkan-validation-layers
      ];
    };

    # boot = lib.mkIf (!nvidia.enabled) {
    #   kernelModules = [
    #     "nouveau"
    #   ];
    #   kernelParams = [
    #     # TODO :: why?
    #     "nouveau.config=NvGspRM=1"
    #     "nouveau.debug=info,VBIOS=info,gsp=debug"
    #     # "module_blacklist=i915" # fixes black screen issue?
    #     # "drm.debug=14"
    #     # "log_buf_len=16M"
    #   ];
    # };
  };
  meta = { };
}
