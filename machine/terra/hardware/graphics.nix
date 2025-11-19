{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  # nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
  nvidia = config.hardware.nvidia;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    environment.variables = lib.mkIf nvidia.enabled {
      EXTRA_SWAY_ARGS = "--unsupported-gpu";
      WLR_NO_HARDWARE_CURSORS = toString 1;
      XWAYLAND_NO_GLAMOR = toString 1; # supposed to help with flickering under xwayland windows
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # :eyeroll:
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = false; # doesn't support pascall (10xx series)
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      nvidiaPersistenced = false;
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
