{
  description = "Nix configuration - personal desktop computer";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysbase = {
      url = "github:signalwalker/nix.sys.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    syshome = {
      url = "github:signalwalker/nix.sys.home";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    homelib = {
      url = "github:signalwalker/nix.home.lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.home-manager.follows = "home-manager";
    };
    homebase = {
      url = "github:signalwalker/nix.home.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.home-manager.follows = "home-manager";
    };
    homedesk = {
      url = "github:signalwalker/nix.home.desktop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.homebase.follows = "homebase";
      inputs.mozilla.follows = "mozilla";
      inputs.ash-scripts.follows = "ash-scripts";
      inputs.polybar-scripts.follows = "polybar-scripts";
      inputs.wired.follows = "wired";
    };
    homedev = {
      url = "github:signalwalker/nix.home.dev";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.homebase.follows = "homebase";
      inputs.mozilla.follows = "mozilla";
    };
    homemedia = {
      url = "github:signalwalker/nix.home.media";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    # base
    # multi
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
    };
    # desk
    ash-scripts = {
      url = "github:signalwalker/scripts-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mozilla.follows = "mozilla";
    };
    ## x11
    polybar-scripts = {
      url = "github:polybar/polybar-scripts";
      flake = false;
    };
    wired = {
      url = "github:Toqozz/wired-notify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    with builtins; let
      std = nixpkgs.lib;
      hlib = inputs.homelib.lib;
      home = hlib.home;
      signal = hlib.signal;
      sys = hlib.sys;
      machines = ["artemis" "terra"];
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      nixosModules = std.genAttrs machines (machine: {lib, ...}: {
        options = {};
        imports = [
          inputs.sysbase.nixosModules.default
          inputs.syshome.nixosModules.default
          ./nixos/system.nix
          ./nixos/nix.nix
          ./machine/${machine}.nix
        ];
        config = {
          networking.hostName = machine;
          networking.domain = "local";
          home-manager.users = self.homeConfigurations;
          nixpkgs.overlays = [
            inputs.mozilla.overlays.rust
            inputs.mozilla.overlays.firefox
          ];
        };
      });
      homeConfigurations.ash = {config, ...}: {
        imports = [
          inputs.homebase.homeManagerModules.default
          inputs.homedev.homeManagerModules.default
          inputs.homedesk.homeManagerModules.default
          inputs.homemedia.homeManagerModules.default
          ./hm/guix.nix
        ];
        config = {
          home.username = "ash";
          home.homeDirectory = "/home/${config.home.username}";

          nixpkgs.overlays = [
            inputs.mozilla.overlays.rust
            inputs.mozilla.overlays.firefox
          ];

          programs.guix.enable = true;
          # services.xremap.enable = lib.mkForce false;
          # services.xremap.services."primary".settings.modmap = [{remap."f20" = "micmute";}];
          signal.desktop.x11.enable = false;
          signal.desktop.wayland.compositor.sway.enable = true;
          signal.desktop.wayland.taskbar.enable = true;

          home.keyboard = {
            model = "asus_laptop";
            layout = "us";
            options = [
              "caps:hyper"
              "grp_led:caps"
            ];
          };
        };
      };
      nixosConfigurations = std.mapAttrs (machine: module:
        std.nixosSystem {
          system = null; # set in `config.nixpkgs.crossSystem`
          modules = [
            module
          ];
          lib = std.extend (final: prev: {
            signal = hlib;
          });
        })
      self.nixosModules;
    };
}
