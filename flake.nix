{
  description = "My flake with dream2nix packages";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, dream2nix, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        myapp-nodep = dream2nix.lib.evalModules {
          packageSets.nixpkgs =
            inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};
          modules = [
            ./apps/myapp-nodep
            {
              paths.projectRoot = ./.;
              # can be changed to ".git" or "flake.nix" to get rid of .project-root
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
            }
          ];
        };

        myapp = dream2nix.lib.evalModules {
          packageSets.nixpkgs =
            inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};
          modules = [
            ./apps/myapp
            {
              paths.projectRoot = ./.;
              # can be changed to ".git" or "flake.nix" to get rid of .project-root
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
            }
          ];
        };


      in with pkgs; rec {
        # Development environment
        devShells.default = mkShell {
          name = "dream2nix-npm-workspace-test";
          nativeBuildInputs = [ nodejs ];
        };

        packages = {
          inherit myapp-nodep myapp;
          default = myapp-nodep;
        };
      });

}
