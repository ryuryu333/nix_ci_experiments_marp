{
  description = "Marp environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    let
      supportSystems = with flake-utils.lib.system; [
        x86_64-linux
      ];
    in
    flake-utils.lib.eachSystem supportSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            marp-cli
            chromium # for generate PDF by marp
            fontconfig # for configuring fonts
            go-task # task runner
          ];
          # create $FONTCONFIG_FILE in env
          # set FONTCONFIG_FILE to use nix-controlled fonts via fontconfig
          # check available fonts in devShell: bash -c "fc-list"
          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = with pkgs; [
              hachimarupop
              noto-fonts-cjk-sans
            ];
          };
        };
      }
    );
}
