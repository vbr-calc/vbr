---
permalink: /gettingstarted/installation/
title: ""
---

# Installation
The code is in MATLAB, but it is functional in [GNU Octave](https://www.gnu.org/software/octave/).

## Download
Installation is as simple as downloading the code, of which there are two options:

* installing from git
* installing via download

Both options (described below) will give you the choice of installing the latest stable version, previous versions or the latest development version. 

### installing from git

To install with git, clone the repository, https://github.com/vbr-calc/vbr (NOTE: if you might be interested in contributing code, you can instead fork the repository and then clone your fork). 

```shell
$ git clone https://github.com/vbr-calc/vbr.git
```

After cloning, you'll be on the `main` branch, which is the latest development version. To check out the latest stable version, run the following 

```shell
$ git fetch --all 
$ git checkout -b origin/stable
``` 

To checkout a specific version of the VBRc, you need to checkout the corresponding version tag. Run
the following to see a list of available versions

```shell
$ git tag -l --sort=-v:refname
v1.2.0
v1.1.2
v1.1.1
v1.1.0
v1.0.1
v0.99.4
v0.99.3
v0.99.2
v0.99.1
v0.99.0
```

to checkout a specific version:

```shell 
$ git checkout v1.1.1
```

### installing via download 

To download the code without git, you can visit the github [release page](https://github.com/vbr-calc/vbr/releases) and download a zip file of your choice. Here's a [direct link to the latest stable release](https://github.com/vbr-calc/vbr/releases/latest).

## Initializing the VBR Calculator
To use the VBR Calculator, it needs to be in your MATLAB path. On opening MATLAB, add the top level directory to your MATLAB path (relative or absolute path) and run vbr_init to add all the required directories to your path:

```matlab
vbr_path='~/src/vbr/';
addpath(vbr_path)
vbr_init
```

If desired, you can permanently add the vbr directory to your path and even call `vbr_init` on opening MATLAB by adding the above lines to the `startup.m` file (see [here](https://www.mathworks.com/help/matlab/ref/startup.html?searchHighlight=startup.m) for help).

## Notes for GNU Octave users

The VBR Calculator also works in GNU Octave! Some of the example `Projects` may require some extra packages:

* [How to install packages](https://octave.org/doc/interpreter/Installing-and-Removing-Packages.html)
* [IO package](https://octave.sourceforge.io/io/index.html)
* [statistics package](https://octave.sourceforge.io/statistics/index.html)
