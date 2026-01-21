{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.services.desktopManager.manager == "hyprland") {
    environment.systemPackages = [
      inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.hyprqt6engine
    ];
    programs.hyprland = {
      enable = true;
      systemd.setPath.enable = false; # TODO :: why
      xwayland.enable = true;
      withUWSM = true;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # portalPackage =
      #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    # stylix.targets.qt = {
    #   platform = lib.mkForce "hyprqt6engine";
    # };
    qt = {
      # platformTheme = lib.mkForce null;
      style = lib.mkForce null;
    };
    environment.variables = {
      QT_QPA_PLATFORMTHEME = lib.mkForce "hyprqt6engine";
    };
  };
  meta = { };
}
