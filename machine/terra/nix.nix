{
  config,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    environment.defaultPersistMountpoint = "/fake-persist";
    environment.persistence.${config.system.persist.defaultMount}.enable = lib.mkForce false;

    nix.settings = {
      substituters = [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };
    nixpkgs.config = {
      cudaSupport = true;
      # cudaCapabilities = [ "7.5" ];
    };
  };
  meta = { };
}
