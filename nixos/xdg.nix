{
  pkgs,
  ...
}:
{
  config = {
    xdg = {
      terminal-exec = {
        enable = true;
        settings = {
          default = [
            "kitty.desktop"
          ];
        };
      };
      sounds.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-termfilechooser
        ];
        config = {
          common = {
            # use termfilechooser instead of whatever else
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          };
        };
      };
      # portal - see nixos/system/display
    };
  };
  meta = { };
}
