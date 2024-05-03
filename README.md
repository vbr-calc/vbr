# The Very Broadband Rheology (VBR) Calculator
**Licensing**: MIT License (see end of this document)

**Citing**: Please see the [How to Cite](#how-to-cite) section at the end of this document if using the VBRc for your research.

**Funding**: The VBR calculator has been developed with funding from the following NSF grants (PI Holtzman unless otherwise noted): EAR 1736165 (Earthscope, co-PI C. Havlin), EAR 13-15254 (Geophysics, PI J. Davis), EAR 1056332 (Geophysics- CAREER).

Further documentation available at [https://vbr-calc.github.io/vbr/](https://vbr-calc.github.io/vbr/).


## Overview

The Very Broadband Rheology Calculator (VBRc) provides a useful framework for calculating material properties from thermodynamic state variables (e.g., temperature, pressure, melt fraction, grain size) using a wide range of experimental scalings. The VBRc at present contains constitutive models only for olivine, but may be applied to other compositions (at your own risk). The main goal is to allow easy comparison between methods for calculating anelastic-dependent seismic properties, but the VBRc can also be used for calculating steady state viscosity, pure elastic (anharmonic) seismic properties and more. It can be used to fit and analyze experimental data, infer thermodynamic state from seismic measurements, predict measurable properties from geodynamic models, for example.  

The code is in MATLAB and is also functional in [GNU Octave](https://www.gnu.org/software/octave/). If you're interested in using the VBRc with python, check out the experimental [pyVBRc](https://github.com/vbr-calc/pyVBRc).

To install, see the [instructions in the main documentation](https://vbr-calc.github.io/vbr/gettingstarted/installation/).

The remainder of this README contains information on:
1. [Bug Reporting and User Support](#bug-reporting-and-user-support)
2. [Basic Usage](#basic-usage)
3. [Getting Help](#getting-help)
4. [Contributing to the VBRc](#contributing-to-the-vbrc)
5. [How to Cite](#how-to-cite)

## Bug Reporting and User Support

Found a bug? [Open an issueon github](https://github.com/vbr-calc/vbr/issues/new)! Got a question? Join our slack channel at [vbr-calc.slack.com](https://join.slack.com/t/vbr-calc/shared_invite/enQtODI0MTk4NzIxNzkzLTZlYjMwYTc4MTVkOTg2ZDgyNTQxNTAxNjc2NmNkMzA2MmVjOTJkYjYzNjc1ZDJhNzg5ZWU2MzE4OTEyNmMxNGU)!


# Basic Usage

The following outlines the basic usage for the VBR calculator. Additionally, there is a growing number of examples in  Projects/ to illustrate more complex usage, particularly in developing a statistical framework for comparing predicted mechanical properties to observed properties.  

### Directory structure
The code is divided into two primary subdirectories: `vbr` and `Projects`.
* `./vbr`: the inner guts of the VBR calculator. The subdirectory `./vbr/vbrCore/functions/` contains the functions in which the actual methods are coded. For example, functions beginning `Q_` are functions related to anelastic methods.
* `./Projects`: each subdirectory within this directory is an example of using the VBR Calculator in a wider "Project." These projects are self-contained codes that use the VBR Calculator in a broader context:
 * `vbr_core_examples`: scripts that simply call VBR in different ways
 * `1_LabData`: functions that call VBR for experimental conditions and materials
 * `mantle_extrap_*`: 3 directories demonstrating how to call VBR for a range of mantle conditions by (1) generating a look up table (LUT, `mantle_extrap_LUT`), (2) using an the analytical solution for half space cooling (`mantle_extrap_hspace`) and (3) using a numerical solution of half space cooling (`mantle_extrap_FM`) .
 * `LAB_fitting_bayesian` a demonstration of how one can use the VBR Calculator in a forward modeling framework to investigate seismic observations.

Note that you should write your code that uses vbr in directories outside the vbr github repository, unless you plan on submitting them to the repository (see the `DevelopmentGuide.md` if that's the case).

### Initialize VBR

To start, add the top level directory to your Matlab path (relative or absolute path) and run vbr_init to add all the required directories to your path:
```
vbr_path='~/src/vbr/';
addpath(vbr_path)
vbr_init
```

### Initialize Methods List

The VBR Calculator is built around Matlab structures. All direction and data is stored in the ```VBR``` structure, which gets passed around to where it needs to go. ```VBR.in``` contains the user's input. ```VBR.out``` contains the results of any calculations.

**First**, the user must supply a cell array called ```methods_list``` for each property for which they want to calculate:
```Matlab
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.viscous.methods_list={'HK2003','HZK2011'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};
```

Each method will have a field in ```VBR.out```  beneath the property, e.g.,

```Matlab
VBR.out.elastic.anharmonic
VBR.out.viscous.HK2003
VBR.out.anelastic.eburgers_psp
VBR.out.anelastic.andrade_psp
```
beneath which there will be fields for the output for the calculations, e.g., ```VBR.out.anelastic.andrade_psp.Q``` for quality factor Q (attenuation=Q<sup>-1</sup>).

After VBR is initialized, a list of available methods can be printed by running `vbrListMethods()`. For theoretical background on the different methods, see the accompanying VBR Calculator Manual.

### Initialize the State Variables

The input structure ```VBR.in.SV``` contains the state variables that define the conditions at which you want to apply the methods. The following fields **MUST** be defined:

```Matlab
%  frequencies to calculate at
   VBR.in.SV.f = logspace(-2.2,-1.3,4); % [Hz]

%  size of the state variable arrays. arrays can be any shape
%  but all arays must be the same shape.
   n1 = 1;

   VBR.in.SV.P_GPa = 2 * ones(n1,1); % pressure [GPa]
   VBR.in.SV.T_K = 1473 * ones(n1,1); % temperature [K]
   VBR.in.SV.rho = 3300 * ones(n1,1); % density [kg m^-3]
   VBR.in.SV.sig_MPa = 10 * ones(n1,1); % differential stress [MPa]

   VBR.in.SV.phi = 0.0 * ones(n1,1); % melt fraction
   VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,1); % grain size [um]

%  optional state variables
   VBR.in.SV.chi=1*ones(n1,1); % composition fraction: 1 for olivine, 0 for crust (OPTIONAL, DEFAULT 1)
   VBR.in.SV.Ch2o = 0 * ones(n1,1) ; % water concentration  (OPTIONAL, DEFAULT 0)

```

All SV arrays must be the same size and shape, except for the frequency ```VBR.in.SV.f```. They can be any length and shape as long as they are the same. Frequency dependent variables store the frequency dependencein an extra dimension of the output. If ```shape(VBR.in.SV.T)``` is (50,100) and ```numel(VBR.in.SV.f)``` is 3, then  ```shape(VBR.out.anelastic.eburgers_psp.V)``` will be (50,100,3).

### Adjust parameters (optional)

The VBR calculator allows the user to change any parameter they see fit. Parameters are stored in the VBR.in.(property).(method) structure, e.g.:

```Matlab
VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]
VBR.in.viscous.HZK2011.diff.Q=350e3; % diffusion creep activation energy
```

The default parameters are stored in ```vbr/vbrCore/params/``` and can be loaded and explored with

```Matlab
VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
VBR.in.viscous.HZK2011=Params_Viscous('HZK2011'); % HZK2011 params
```

When changing parameters from those loaded by default, you can either load all the parameters then overwrite them or in most cases you can simply set the parameters without loading the full set of parameters.

### Run the VBR Calculator

The VBR Calculator executes calculations by passing the ```VBR``` structure to the ``VBR_spine()```:

```Matlab
[VBR] = VBR_spine(VBR) ;
```

### Extracting results

Results are stored in ```VBR.out``` for each property type and method:

```Matlab
VBR.out.elastic.anharmonic.Vsu % unrelaxed seismic shear wave velocity
VBR.out.anelastic.eburgers_psp.V % anelastic-dependent seismic shear wave velocity
VBR.out.viscous.HZK2011.eta_total % composite steady state creep viscosity
```

### Notes for GNU Octave users

The VBR Calculator nominally works in GNU Octave, but you may find that you need to install some packages.

https://octave.sourceforge.io/io/index.html
https://octave.sourceforge.io/statistics/index.html
https://octave.org/doc/interpreter/Installing-and-Removing-Packages.html

# Getting Help

See the full documentation page on [Contributing and Getting Help](https://vbr-calc.github.io/vbr/contrib/contributing/)
for ways to reach out or [post a github issue](https://github.com/vbr-calc/vbr/issues/new)!

# Contributing to the VBRc

The VBRc is open to community contributions! New methods, new examples, documentation fixes, bug fixes!

We follow a typical open source workflow. To submit new features:

* create your fork of the VBRc repo
* checkout a new branch
* do work on your new branch
* push those changes to your fork on github
* submit a pull request back to the main VBRc repo

If you're adding a new method, be sure to add a new test (see the following section) and add a note to the active release notes (`release_notes.md`) with a short summary of your work.

If you're new to git, github or contributing to open source projects, the following article has a nice overview with sample git commands: [GitHub Standard Fork & Pull Request Workflow](https://gist.github.com/Chaser324/ce0505fbed06b947d962).

## Test Suite

When you submit a pull request, a suite of tests will run via github actions. These actions test functionality in both MATLAB and Octave. You can run the full test suite locally by running the `run_all_tests.m` script in the top level of the repository. See `vbr/testing/README.md` for details on adding new tests and running subsets of tests.

## MATLAB and Octave compatibility (and pre-commit)

Ensuring that code runs on both MATLAB and Octave can be tricky. Please avoid using MATLAB Toolboxes or 3rd party Octave packages. If you would like to add functionality that requires either of these, please open a discussion via the Issues page or reach out on Slack and we can figure out ways to minimize impact and properly test new functionality.

If you use Python for other projects, you can use some pre-commit checks here to help catch some errors. From a fresh environment, run `pip install -r dev_requirements.txt` to install some extra dependencies and then run

```
pre-commit install
```

After which, any time you run `git commit`, pre-commit will run some simple checks for you. As of now, the only check ensures that `.m` files do not contain the pound/hashtag symbol, which is a valid comment symbol in octave but not matlab and is a common mistake when your other projects are in Python...

## Release Notes

This section contains notes for the VBRc maintainers on creating releases.

To release, create a new version tag locally:

```
$ git tag v0.99.5
```
and push it up to gitub

```
$ git push upstream v0.99.5
```

this will trigger a github action that drafts a release based on the current version of `release_notes.md`. Go to github, edit the release and then hit publish when ready.

### release cleanup:

After publishing, do the following:

- Merge with the relevant stable series branch (`stable_0.x`, etc.)

Then commit and push the following changes to `main`:

- Copy/paste `release_notes.md` into `release_history.md`, reset `release_notes.md` for active development.
- Bump the version in `vbr/support/vbr_version.m` appropriately


# How to Cite

The primary VBRc "methods paper" to cite is:

Havlin, C., Holtzman, B.K. and Hopper, E., 2021. Inference of thermodynamic state in the asthenosphere from anelastic properties, with applications to North American upper mantle. Physics of the Earth and Planetary Interiors, 314, p.106639, [https://doi.org/10.1016/j.pepi.2020.106639](https://doi.org/10.1016/j.pepi.2020.106639).

Additionally, you're welcome to cite the software DOI directly if you would like to point your readers directly to the software (but please also cite the methods paper above):

[![DOI](https://zenodo.org/badge/225459902.svg)](https://zenodo.org/badge/latestdoi/225459902)

We also encourage you to cite the underlying primary sources that developed the scaling methods implemented by the VBRc, particularly if comparing results from different methods. Many of the methods actually have citations built into the code! For example,

```
addpath('path/to/vbrc/');
vbr_init
params = Params_Anelastic('eburgers_psp');
disp(params.citations)
```
will display relevant citations for the `eburgers_psp` method.

**If you publish with the VBRc**, please also send us a note and we can add you to our [VBR in the wild](https://vbr-calc.github.io/vbr/relatedpubs/) publication list.

## MIT License ##

Copyright (c) 2019-2023 Benjamin Holtzman, Christopher Havlin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
