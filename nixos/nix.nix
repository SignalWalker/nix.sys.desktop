{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.lix-module.nixosModules.default
    inputs.agenix.nixosModules.age
    inputs.nix-index-database.nixosModules.nix-index
  ];
  config = {
    assertions = [
      {
        assertion = config.nix.settings.access-tokens == [ ];
        message = "nix access tokens should not be present in config files; use nix-auth instead";
      }
    ];

    environment.systemPackages = [
      inputs.nix-auth.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
      };
      settings = {
        # NOTE ::
        access-tokens = [ ];
      };
    };

    programs.command-not-found.enable = false; # doesn't work in a pure-flake system

    nixpkgs = {
      overlays = [
        inputs.mozilla.overlays.rust
        inputs.mozilla.overlays.firefox
        # inputs.wayland.overlays.default
        inputs.agenix.overlays.default

        inputs.thaw.overlays."package/thaw"

        inputs.nix-alien.overlays.default
      ];

      config = {
        permittedInsecurePackages = [
          "electron-39.8.10"
        ];
        nvidia.acceptLicense = true;
      };
    };
  };
  meta = { };
}
