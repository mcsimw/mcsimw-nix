{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      # Follow same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, wrapper-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { pkgs, lib, ... }:
        let
          allWrappers = wrapper-manager.lib.build {
            inherit pkgs;
            modules = [
              {
                wrappers = {
                  foot = {
                    basePackage = pkgs.foot;
                    flags = [ "--config=${./foot.ini}" ];
                  };
                  ripgrep = {
                    basePackage = pkgs.ripgrep;
                  };
                  nushell = {
                    basePackage = pkgs.nushell;
                    pathAdd = [
                      pkgs.starship
                      pkgs.carapace
                    ];
                  };
                };
              }
            ];
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              dos2unix.enable = true;
            };
            settings.formatter = {
              deadnix.priority = 1;
              statix.priority = 2;
              nixfmt.priority = 3;
              dos2unix.priority = 4;
            };
          };
          packages.default = allWrappers;
        };
    };
}
