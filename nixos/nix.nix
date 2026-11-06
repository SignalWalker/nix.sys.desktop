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
        assertion = config.nix.settings ? access-tokens -> config.nix.settings.access-tokens == [ ];
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
        extra-substituters = [
          "https://lan-mouse.cachix.org/"
        ];
        extra-trusted-public-keys = [
          "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
        ];
      };
    };

    programs.command-not-found.enable = false; # doesn't work in a pure-flake system

    nixpkgs = {
      overlays = [
        inputs.mozilla.overlays.rust
        inputs.mozilla.overlays.firefox
        # inputs.wayland.overlays.default
        inputs.agenix.overlays.default

        # inputs.thaw.overlays."package/thaw"

      ];

      config = {
        problems.handlers = {
          "gtk+".broken = "warn";
        };
        permittedInsecurePackages = [
        ];
        nvidia.acceptLicense = true;
      };
    };
  };
  meta = { };
}
