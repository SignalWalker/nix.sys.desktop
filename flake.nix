{
  description = "Nix configuration - personal computer";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    alejandra = {
      url = github:kamadorueda/alejandra;
      inputs.nixpkgs.follows = "nixpkgs";
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
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      signalModules.default = {
        name = "sys.personal.default";
        dependencies = hlib.signal.dependency.default.fromInputs {
          inherit inputs;
          filter = [ "homelib" ];
        };
        outputs = dependencies: {
          homeManagerModules.default = { lib, ... }: {
            imports = [ ./home-manager.nix ];
          };
        };
      };
      homeConfigurations = home.genConfigurations self;
      packages = home.genActivationPackages self.homeConfigurations;
      apps = home.genActivationApps self.homeConfigurations;
    };
}
