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
  imports = lib.signal.fs.path.listFilePaths ./terra;
  config = {
    services.atuin = {
      enable = true;
      host = "0.0.0.0";
      openRegistration = false;
      openFirewall = true;
      port = 8398;
    };
    services.foundryvtt = {
      enable = true;
      minifyStaticFiles = true;
      upnp = true;
    };
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
    services.jellyseerr = {
      enable = true;
    };
    networking.firewall.allowedUDPPorts = [
      30000 # foundry
      5055 # jellyseerr
    ];
    networking.firewall.allowedTCPPorts = [
      30000 # foundry
      5055 # jellyseerr
    ];
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
    };
  };
  meta = {};
}
