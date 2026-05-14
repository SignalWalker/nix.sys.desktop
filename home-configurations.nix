inputs: top: {
  ash =
    {
      ...
    }:
    {
      imports = [
        inputs.homebase.homeModules.default
        inputs.homedesk.homeModules.default

        inputs.nix-index-database.homeModules.nix-index
        inputs.agenix.homeManagerModules.age

        ./hm/shared.nix
        # TODO :: per-machine homeconfig
        # ./hm/${machine}.nix
      ];
      config = {
        programs.guix.enable = false;

        # desktop.wayland.compositor.sway.enable = true;

        # wayland.windowManager.hyprland.pyprland.package =
        #   inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.pyprland;

        home.packages = [
          # (openmw-dev.overrideAttrs (
          #   final: prev: {
          #     src = inputs.openmw-src;
          #   }
          # ))
          # openmw-validator
          # plox
          # umo # build failure 2025-05-24
          # delta-plugin
          # groundcoverify
        ];
      };
    };
}
