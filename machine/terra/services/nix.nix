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
      settings.secret_key_files = [secrets.nixStoreKey.path];
    };
  };
  meta = {};
}
