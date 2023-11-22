{ lib, config, dream2nix, ... }: {
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-json-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  deps = { nixpkgs, ... }: { inherit (nixpkgs) gnugrep stdenv typescript; };
  nodejs-granular-v3 = {
    buildScript = ''
      tsc ./app.ts
      mv app.js app.js.tmp
      echo "#!${config.deps.nodejs}/bin/node" > app.js
      cat app.js.tmp >> app.js
      chmod +x ./app.js
      patchShebangs .
    '';
  };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = lib.mkForce "myapp";
  version = lib.mkForce "1.0.0";

  mkDerivation = {
    nativeBuildInputs = with config.deps; [ typescript ];
    src = lib.cleanSource ./.;
    checkPhase = ''
      ./app.js | ${config.deps.gnugrep}/bin/grep -q "Hello, World! - 3"
    '';
    doCheck = true;
  };
}
