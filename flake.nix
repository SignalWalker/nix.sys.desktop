{
  description = "Nix configuration - personal desktop computer";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
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
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    deploy-rs,
    ...
  }:
    with builtins; let
      std = nixpkgs.lib;
      machines = ["artemis" "terra"];
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      nixosModules = std.genAttrs machines (machine: {lib, ...}: {
        options = {};
        imports = [
          inputs.sysbase.nixosModules.default
          inputs.syshome.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          inputs.foundryvtt.nixosModules.foundryvtt
          ./nixos/system.nix
          ./nixos/nix.nix
          ./machine/${machine}.nix
        ];
        config = {
          networking.hostName = machine;
          networking.domain = "local";
          home-manager = {
            users = self.homeConfigurations;
          };
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

          inputs.nix-index-database.hmModules.nix-index

          ./hm/guix.nix
        ];
        config = {
          nixpkgs.overlays = [
            inputs.mozilla.overlays.rust
            inputs.mozilla.overlays.firefox
          ];

          programs.guix.enable = false;
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
          system = null; # set in `config.nixpkgs.hostPlatform`
          modules = [
            module
          ];
          lib = std.extend (final: prev: {
            signal = inputs.homelib.lib;
          });
        })
      self.nixosModules;

      deploy.nodes = std.mapAttrs (machine: config: {
        hostname = "${machine}.local";
        remoteBuild = machine == "terra";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos config;
        };
      });

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
