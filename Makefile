init:
	npm install

regenerate:
	@if command -v node >/dev/null 2>&1; then \
		npm run ergogen:build && \
		mv ./ergogen/output/pcbs/production.kicad_pcb ./ergogen/kicad/; \
	else \
		ncolors=$$(tput colors) && \
		if [ -n "$$ncolors" ] && [ $$ncolors -gt 2 ]; then \
			echo -e "\033[0;31mERROR\033[0m: Node.js is not installed! Try running '\033[1m\033[35mnix develop\033[0m' to enter a dev shell."; \
		else \
			echo "ERROR: Node.js is not installed! Try running 'nix develop' to enter a dev shell."; \
		fi; \
	fi
