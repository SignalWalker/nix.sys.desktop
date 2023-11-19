{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  input = config.signal.input;
in {
  options = with lib; {
    signal.input = {
      enable = (mkEnableOption "input configuration") // {default = true;};
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf input.enable {
    environment.systemPackages = [
      pkgs.xorg.setxkbmap
    ];
    services.xserver = {
      xkb = {
        options = "caps:hyper,grp_led:caps";
        extraLayouts."hypersuper" = {
          description = "Ensures correct modifier mapping for hyper and super.";
          symbolsFile = ./input/symbols/hypersuper;
          languages = ["eng"];
        };
        layout = "hypersuper(us)";
      };
    };

    programs.wshowkeys.enable = true;
  };
  meta = {};
}
