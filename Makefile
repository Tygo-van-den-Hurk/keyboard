regenerate:
	node ergogen/src/cli.js ergogen.layout.yaml -o output/
	mv output/pcbs/production.kicad_pcb wiring/production.kicad_pcb