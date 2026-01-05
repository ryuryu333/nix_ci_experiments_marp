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
        aarch64-darwin
      ];
    in
    flake-utils.lib.eachSystem supportSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # tool list for devShells
        marp_build_tools = with pkgs; [
          marp-cli
          fontconfig # for configuring fonts
          go-task # task runner
          (lib.optionals (system != "aarch64-darwin") [
            # not available on aarch64-darwin
            chromium # for generate PDF by marp
          ])
        ];

        bash_script_development_tools = with pkgs; [
          (bats.withLibraries (p: [
            p.bats-assert
            p.bats-support
          ])) # for test
          shellcheck # linter
          shfmt # formatter
        ];

        github_actions_development_tools = with pkgs; [
          gh
          pinact # pin GitHub Actions versions
          actionlint # linter (syntax & logic)
          ghalint # linter (security best practices)
          zizmor # linter (common security issues)
          act # local workflow runner
          docker # for act
          colima # for docker
          prettier # formatter
        ];

        # font config file for devShells
        # set FONTCONFIG_FILE to use nix-controlled fonts via fontconfig
        # check available fonts in devShell: bash -c "fc-list"
        FONTCONFIG_FILE = pkgs.makeFontsConf {
          fontDirectories = with pkgs; [
            hachimarupop
            noto-fonts-cjk-sans
          ];
        };
      in
      {
        devShells = rec {
          ci = pkgs.mkShell {
            packages = [
              marp_build_tools
            ];
            inherit FONTCONFIG_FILE; # create $FONTCONFIG_FILE in env
          };
          local = pkgs.mkShell {
            packages = [
              marp_build_tools
              bash_script_development_tools
              github_actions_development_tools
            ];
            inherit FONTCONFIG_FILE;
          };
          default = local;
        };
      }
    );
}
