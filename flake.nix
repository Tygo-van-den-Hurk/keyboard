{
  description = "The flake that is used add Node and a couple of other programs to the shell.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;

    in rec {

      devShell = pkgs.mkShell {
        
        buildInputs = (
          (with pkgs; [ kicad nodejs_22 gnumake freecad ]) ++ 
          (with self.packages.${system}; [ ergogen ])
        );

        shellHook = (''
          # if the terminal supports color.
          if [[ -n "$(tput colors)" && "$(tput colors)" -gt 2 ]]; then
            echo -e "\033[1;32mStarted\033[0m a \033[1;31mNode\033[0m Development Shell powered by \033[1;34mNix\033[0m."
            echo -e "Using \033[1;33m$(node --version)\033[00m."
            export PS1="(\033[1m\033[35mDev-Shell\033[0m) $PS1"
          else 
            echo "Started a Node Development Shell powered by Nix."
            echo "Using $(node --version)."
            export PS1="(Dev-Shell) $PS1"
          fi''
        );
      };

      packages = {

        pcb = pkgs.stdenv.mkDerivation rec {
          name = "pcb";
          src = ./hardware;

          buildPhase = ''
            runHook preBuild 

            ${self.packages.${system}.ergogen}/bin/ergogen --clean --output output --debug src
            
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            cp output/pcbs/production.kicad_pcb $out
            
            runHook postInstall
          '';
        };

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


    }
  );
}