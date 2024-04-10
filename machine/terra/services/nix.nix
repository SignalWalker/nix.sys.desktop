{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  secrets = config.age.secrets;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    age.secrets.nixStoreKey = {
      file = ./nix/nixStoreKey.age;
    };
    nix = {
      sshServe = {
        write = true;
      };
      settings.secret-key-files = [secrets.nixStoreKey.path];
    };
  };
  meta = {};
}
