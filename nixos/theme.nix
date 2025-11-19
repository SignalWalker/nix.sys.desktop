{
  pkgs,
  ...
}:
{
  config = {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
      overlays = {
        enable = true;
      };
      cursor = {
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePineDawn-Linux";
        size = 24;
      };
      opacity = {
        terminal = 0.96;
      };
      fonts = {
        serif = {
          package = pkgs.iosevka-bin.override { variant = "Etoile"; };
          name = "Iosevka Etoile";
        };
        sansSerif = {
          package = pkgs.iosevka-bin.override { variant = "Aile"; };
          name = "Iosevka Aile";
        };
        monospace = {
          package = pkgs.iosevka-bin;
          name = "Iosevka Term";
        };
        emoji = {
          package = pkgs.openmoji-color;
          name = "OpenMoji Color";
        };
      };
    };
  };
  meta = { };
}
