# This shell.nix file is designed for use with cabal build
# It does **not** aim to replace Cabal

# Maintaining this file:
#
#     - Bump the nixpkgs version using `niv update nixpkgs`
#     - To edit the set of local packages:
#       1. Declare them in nix/default.nix
#       2. Edit the list of packages below
#
# For more details: https://github.com/NixOS/nixpkgs/blob/20.03/pkgs/development/haskell-modules/make-package-set.nix#L256


{ compiler ? "default",
  withHoogle ? false,
  nixpkgs ? import ./nix {}
 }:

with nixpkgs;

let defaultCompiler = "ghc" + lib.replaceStrings ["."] [""] haskellPackages.ghc.version;
    haskellPackagesForProject =
        if compiler == "default"
            then ourHaskell.packages.${defaultCompiler}
            else ourHaskell.packages.${compiler};

    packages = p: [ p.haskell-language-server
                    p.ghcide
                    p.hie-compat
                    p.hls-plugin-api
                    p.hls-tactics-plugin
                    p.hls-hlint-plugin
                    p.hls-explicit-imports-plugin
                    p.hls-retrie-plugin
                  ];

    isSupported = compiler == "default" || compiler == defaultCompiler;
in
haskellPackagesForProject.shellFor {
  inherit withHoogle;
  doBenchmark = true;
  packages = p: if isSupported then packages p else [p.ghc-paths];
  buildInputs = [
    gmp
    zlib
    ncurses

    haskellPackages.cabal-install
    haskellPackages.hlint
    haskellPackages.ormolu
    haskellPackages.stylish-haskell
  ];
  src = null;
  shellHook = ''
    export LD_LIBRARY_PATH=${gmp}/lib:${zlib}/lib:${ncurses}/lib
    export PATH=$PATH:$HOME/.local/bin
  '';
}
