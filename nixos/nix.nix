{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
      };
      settings = {
        # NOTE :: use nix-auth for this; don't try to put access tokens here
        access-tokens = [ ];
      };
    };

    programs.command-not-found.enable = false; # doesn't work in a pure-flake system
  };
  meta = { };
}
