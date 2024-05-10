{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = with pkgs;
          mkShell {
            name = "Default developpement shell";
            packages = [
              cocogitto
              nixpkgs-fmt
              nodePackages.markdownlint-cli
              pre-commit

              deno
              gum
              hugo
              just
              vhs

              # Latex
              (texlive.combine {
                inherit (texlive)
                  scheme-medium msg tabularray ninecolors lipsum;
              })
              pplatex
              texlab
              zathura

              # Convert PDF to PNG
              ghostscript
            ];
            shellHook = ''
              export PROJ="devops.jesuislibre.org"

              echo ""
              echo "⭐ Welcome to the $PROJ project ⭐"
              echo ""
            '';
          };
      });
}
