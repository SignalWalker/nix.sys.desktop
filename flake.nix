{
  description = "Nix configuration - personal computer";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    alejandra = {
      url = github:kamadorueda/alejandra;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysbase = {
      url = github:signalwalker/nix.sys.base;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homebase.follows = "homebase";
      inputs.homelib.follows = "homelib";
    };
    homelib = {
      url = github:signalwalker/nix.home.lib;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.home-manager.follows = "home-manager";
    };
    homebase = {
      url = github:signalwalker/nix.home.base;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.home-manager.follows = "home-manager";
    };
    homedesk = {
      url = github:signalwalker/nix.home.desktop;
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
      url = github:signalwalker/nix.home.dev;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.homebase.follows = "homebase";
      inputs.mozilla.follows = "mozilla";
    };
    homemedia = {
      url = github:signalwalker/nix.home.media;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.homebase.follows = "homebase";
      inputs.homedesk.follows = "homedesk";
    };
    # base
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # multi
    mozilla = {
      url = github:mozilla/nixpkgs-mozilla;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # desk
    ash-scripts = {
      url = github:signalwalker/scripts-rs;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mozilla.follows = "mozilla";
    };
    ## x11
    polybar-scripts = {
      url = github:polybar/polybar-scripts;
      flake = false;
    };
    wired = {
      url = github:Toqozz/wired-notify;
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
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      signalModules.default = {
        name = "sys.personal.default";
        dependencies = signal.flake.set.toDependencies {
          flakes = inputs;
          filter = [];
          outputs = {
            mozilla.overlays = ["rust" "firefox"];
            sysbase = {
              nixosModules = ["default"];
            };
          };
        };
        outputs = dependencies: {
          homeManagerModules = {lib, ...}: {
            options = with lib; {};
            imports = [];
            config = {
              signal.desktop.x11.enable = false;
              services.xremap.enable = lib.mkForce false;
              services.xremap.services."primary".settings.modmap = [{remap."f20" = "micmute";}];
              signal.desktop.wayland.compositor.sway.enable = true;
              signal.desktop.wayland.taskbar.enable = true;
              wayland.windowManager.sway.extraOptions = [
                "--unsupported-gpu"
              ];
              signal.desktop.wayland.startupCommands = ''
                kitty &
              '';
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
          nixosModules = {lib, ...}: {
            options = with lib; {};
            imports = [];
            config = {};
          };
        };
      };
      homeConfigurations = home.configuration.fromFlake {
        flake = self;
        flakeName = "sys.personal";
        extraModules = [({...}: {config.system.isNixOS = false;})];
      };
      nixosConfigurations = sys.configuration.fromFlake {
        flake = self;
        flakeName = "sys.personal";
        hostNameMap = {__default = "ash-laptop";};
      };
      packages =
        std.recursiveUpdate
        (home.package.fromHomeConfigurations self.homeConfigurations)
        {default = std.mapAttrs' (name: cfg: std.nameValuePair "nixos-${name}" cfg.config.system.build.toplevel) self.nixosConfigurations;};
      apps = home.app.fromHomeConfigurations self.homeConfigurations;
    };
}
