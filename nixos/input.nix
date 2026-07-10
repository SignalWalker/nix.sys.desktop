{
  config,
  pkgs,
  lib,
  ...
}:
let
  input = config.signal.input;
in
{
  options = {
    signal.input = {
      enable = (lib.mkEnableOption "input configuration") // {
        default = true;
      };
    };
  };
  config = lib.mkIf input.enable {
    environment.systemPackages = [
      pkgs.setxkbmap
    ];
    services.xserver = {
      xkb = {
        options = "caps:hyper,grp_led:caps";
        extraLayouts."hypersuper" = {
          description = "Ensures correct modifier mapping for hyper and super.";
          symbolsFile = ./input/symbols/hypersuper;
          languages = [ "eng" ];
        };
        layout = "hypersuper(us)";
      };
    };

    programs.wshowkeys.enable = true;
  };
  meta = { };
}

