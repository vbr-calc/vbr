---
permalink: /gettingstarted/installation/
title: ""
---

# Installation
The code is in Matlab, but it is functional in [GNU Octave](https://www.gnu.org/software/octave/).

## Download
Installation is as simple as downloading the code, of which there are two options:
* Clone from [the github stable branch](https://github.com/vbr-calc/vbr/tree/stable)
* Download a [zip file of the latest stable release](https://github.com/vbr-calc/vbr/releases/latest)

## Initializing the VBR Calculator
To use the VBR Calculator, it needs to be in your Matlab path. On opening Matlab, add the top level directory to your matlab path (relative or absolute path) and run vbr_init to add all the required directories to your path:
```matlab
vbr_path='~/src/vbr/';
addpath(vbr_path)
vbr_init
```

If desired, you can permanently add the vbr directory to your path and even call `vbr_init` on opening Matlab by adding the above lines to the `startup.m` file (see [here](https://www.mathworks.com/help/matlab/ref/startup.html?searchHighlight=startup.m) for help).

## Notes for GNU Octave users

The VBR Calculator nominally works in GNU Octave, but you may find that you need to install some packages:

* [How to install packages](https://octave.org/doc/interpreter/Installing-and-Removing-Packages.html)
* [IO package](https://octave.sourceforge.io/io/index.html)
* [statistics package](https://octave.sourceforge.io/statistics/index.html)
