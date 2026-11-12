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
        inherit (nixpkgs.lib) getExe;
        client = pkgs.buildNpmPackage {
          pname = "client";
          version = "0.1";
          src = ./.;
          # needs to be updated everytime you update npm dependencies
          npmDepsHash = "sha256-yH5X/J5hUer7us999Ic+S4WA3IBEWKb2O2yJqra/ExY=";
          nativeBuildInputs = [ pkgs.pkg-config pkgs.python3 ];
          # npmBuild = "npm run build --workspace=apps/client";
          npmWorkspace = "apps/client";

          # move exported website to $out
          postInstall = ''
            cp -rf apps/client/dist/standalone/* $out
            cp -rf apps/client/public $out/apps/client/
            cp -rf apps/client/dist/static $out/apps/client/dist
          '';
        };
           # ${getExe pkgs.webfs} -F -r ${site} -f index.html -p 8080

        run-client = pkgs.writeShellScriptBin "run-client" ''
            ${getExe pkgs.nodejs} ${client}/apps/client/server.js
          '';

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
          inherit myapp-nodep myapp client run-client;
          default = run-client;
        };
      });

}
