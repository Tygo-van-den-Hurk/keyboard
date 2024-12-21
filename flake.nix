{
  description = "The flake that is used add Node and a couple of other programs to the shell.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
    let

      pkgs = import nixpkgs {
        inherit system;
      };
      
    in rec {

      devShell = pkgs.mkShell {
        
        buildInputs = with pkgs; [ kicad nodejs_22 gnumake ];

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
    }
  );
}