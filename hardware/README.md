> This submodule is for generating the hardware of my keyboard.

[< Back to the main README](../README.md)

# Hardware

- [Hardware](#hardware)
  - [Overview](#overview)
  - [Kicad](#kicad)
  - [Ergogen](#ergogen)
    - [Adding custom footprints](#adding-custom-footprints)

## Overview

This module is used to generate the hardware components. That is: the PCBs, outlines, cases, and points.

## Kicad

Kicad is used for adding the wires to a PCB. Unfortunately every time you update the PCB you'll have to rewire it yourself. So far I've seen no way to do that manually. To update the PCB run:

```BASH
nix run .#update-kicad-pcb
```

We keep the pcb files in the kicad folder to be tracked by version control. Since these are json files and not binary these are really easy to add to version control.

## Ergogen

We use ergogen to build the hardware. Ergogen builds: the PCBs, outlines, cases, and points. To build any of it use:

```BASH
nix build .#pcbs
nix build .#outlines
nix build .#cases
nix build .#points
```

to build any of them. You can also get in a dev shell with ergogen using `nix develop` and then run ergogen manually.

### Adding custom footprints

To add custom footprints, add your footprint to the `src/footprints` folder as `src/footprints/<your-footprint>.js`. Where `<your-footprint>` is the name of your footprint. Ergogen will automatically load them.
