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
  imports =
    [
      "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    ]
    ++ lib.signal.fs.path.listFilePaths ./hardware;
  config = {};
  meta = {};
}
