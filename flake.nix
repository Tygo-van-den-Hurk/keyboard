{
  description = "The flake that is used add Node and a couple of other programs to the shell.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./.config/treefmt.nix;

      in
      rec {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Develop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        devShell = pkgs.mkShell {

          buildInputs = (with pkgs; [ kicad ]) ++ (with self.packages.${system}; [ ergogen ]);

          shellHook = ''
            # if the terminal supports color.
            if [[ -n "$(tput colors)" && "$(tput colors)" -gt 2 ]]; then
              export PS1="(\033[1m\033[35mDev-Shell\033[0m) $PS1"
            else 
              export PS1="(Dev-Shell) $PS1"
            fi

            unset shellHook
            unset buildInputs
          '';
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Run ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        apps = {

          update-pcb = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "update-pcb" ''
                set -e
                directory="$(git rev-parse --show-toplevel)/hardware/kicad/"
                [ -d $directory ] && mkdir --parents $directory
                cp --force ${self.packages.${system}.pcbs}/* $directory
              ''
            );
          };

          watch-pcb = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "watch-pcb" ''
                set -e
                ${pkgs.nodemon}/bin/nodemon \
                  --exec "nix run .#update-pcb" \
                  --watch "./hardware/src/**/*.*"
              ''
            );
          };

        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        packages = {

          #| Hardware

          hardware = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware;

            buildPhase = ''
              runHook preBuild 

              ${self.packages.${system}.ergogen}/bin/ergogen --clean --output output --debug src

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive output/* $out

              runHook postInstall
            '';
          };

          pcbs = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware;

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${self.packages.${system}.hardware}/pcbs/* $out

              runHook postInstall
            '';
          };

          outlines = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware;

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${self.packages.${system}.hardware}/outlines/* $out

              runHook postInstall
            '';
          };

          points = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware;

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${self.packages.${system}.hardware}/points/* $out

              runHook postInstall
            '';
          };

          cases = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware;

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${self.packages.${system}.hardware}/cases/* $out

              runHook postInstall
            '';
          };

          #| Dependencies

          ergogen = pkgs.buildNpmPackage {
            pname = "ergogen";
            version = "4.0.2";

            forceGitDeps = true;

            src = pkgs.fetchFromGitHub {
              owner = "ergogen";
              repo = "ergogen";
              tag = "v4.0.2";
              hash = "sha256-RP+mDjL6M+gHFrQvFd7iZaL2aQXk+6gQEUf0tWaTp3g=";
            };

            npmDepsHash = "sha256-zsC8QcrEy9Ie7xaad/pk5D6wL8NgMdgfymAiGy8vnsY=";

            makeCacheWritable = true;
            dontNpmBuild = true;
            npmPackFlags = [ "--ignore-scripts" ];
            NODE_OPTIONS = "--openssl-legacy-provider";

            doInstallCheck = true;
            nativeInstallCheckInputs = [ pkgs.versionCheckHook ];

            passthru.updateScript = pkgs.nix-update-script { };

            meta = {
              description = "Ergonomic keyboard layout generator.";
              homepage = "https://ergogen.xyz";
              mainProgram = "ergogen";
              license = lib.licenses.mit;
            };
          };
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Flake Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        checks = packages // {
          formatting = treefmtEval.config.build.check self;
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Fmt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        formatter = treefmtEval.config.build.wrapper;

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
      }
    );
}
