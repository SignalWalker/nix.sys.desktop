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
    nix = {
      gc.automatic = false;
    };

    # programs.command-not-found.enable = false; # using `nix-index` (configured from home-manager) instead
  };
  meta = {};
}
