> This submodule is for generating the hardware of my keyboard.

[< Back to the main README](../README.md)

# Hardware

- [Hardware](#hardware)
  - [Overview](#overview)
  - [Kicad](#kicad)
  - [Ergogen](#ergogen)
    - [Adding custom footprints](#adding-custom-footprints)
  - [External Resources](#external-resources)
  - [Components](#components)

## Overview

For the generating the files we need for the hardware we'll be using [ergogen](https://github.com/ergogen/ergogen). [Ergogen](https://github.com/ergogen/ergogen) is a program that allows you to build keyboards from a YAML config file. 

## Kicad

Kicad is used for adding the wires to a PCB. Unfortunately every time you update the PCB you'll have to rewire it yourself. So far I've seen no way to do that manually. To update the PCB run:

```SH
nix run .#update-pcb
```

We keep the pcb files in the kicad folder to be tracked by version control. Since these are text files and not binary these are really easy to add to version control. If you are developing and you want rapid updates to your PCB, you can run:

```SH
nix run .#watch-pcb
```

to automatically update the PCB on any changes.

## Ergogen

We use ergogen to build the hardware. Ergogen builds: the PCBs, outlines, cases, and points. To build any of it use:

```SH
nix build .#pcbs
nix build .#outlines
nix build .#cases
nix build .#points
```

to build any of them. You can also get in a dev shell with ergogen using `nix develop` and then run ergogen manually.

### Adding custom footprints

There is just one problem: Ergogen does not natively support the pro micro I want to use for my keyboard. So to solve this we have to use footprints. Footprints is a way to extend ergogen's functionality beyond it's native capabilities.

To use footprints we have to use the following structure: there has to be a directory called `footprints` and a file called `config.yaml`. The `config.yaml` is where we'll describe our keyboard to ergogen, and in the `footprints` folder we'll put our missing footprints. Thanks to [@Narkoleptika](https://github.com/Narkoleptika)'s hard work (or who ever he got it from) there is a footprint for the pro micro.

If you need any footprint that this repository is missing, you can find it's JavaScript file, and add it to the `./src/footprints/` directory. There are a lot of footprints you can use. Just make sure it's well tested, because a bad footprint could technically destroy your microcontroller.

## External Resources

- [The ergogen docs](https://docs.ergogen.xyz/) for any questions about how ergogen works.
- [Web-based deployments](https://ergogen.ceoloide.com/) for getting a visual impression of what the keys look like.
- [The ergogen v4 guid I used](https://flatfootfox.com/ergogen-introduction/) for a step by step tutorial.

## Components

Here are the components I used for my keyboard:

- Choc key switches 
- a `pro micro` micro controller
- my self made PCB
