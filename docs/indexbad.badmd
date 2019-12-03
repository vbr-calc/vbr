# The Very Broadband Rheology (VBR) Calculator

**Licensing**: MIT License (see end of this document)

**Citing**: Manuscript in prep., please email vbrcalc@gmail.com before using for publishable research. The VBR calculator has been developed with funding from the following NSF grants (PI Holtzman unless otherwise noted): EAR 1736165 (Earthscope, co-PI C. Havlin), EAR 13-15254 (Geophysics, PI J. Davis), EAR 1056332 (Geophysics- CAREER).  

## Overview

The Very Broadband Rheology (VBR) Calculator provides a useful framework for calculating material properties from thermodynamic state variables (e.g., temperature, pressure, melt fraction, grain size) using a wide range of experimental scalings. The VBR Calculator at present contains constitutive models only for olivine, but may be applied to other compositions (at your own risk). The main goal is to allow easy comparison between methods for calculating anelastic-dependent seismic properties, but the VBR Calculator can also be used for calculating steady state viscosity, pure elastic (anharmonic) seismic properties and more. It can be used to fit and analyze experimental data, infer thermodynamic state from seismic measurements, predict measurable properties from geodynamic models, for example.  

At present, the code is in Matlab, but it is functional in [GNU Octave](https://www.gnu.org/software/octave/). There are plans for a python release, pending funding.

## Getting the Code

Two ways to get the code:
* Clone from [the github stable branch](https://github.com/vbr-calc/vbr/tree/stable)
* Download a [zip file of the latest stable release](https://github.com/vbr-calc/vbr/releases/latest)


## Bug Reporting and User Support

Found a bug? Got a question? Join our slack channel at [vbr-calc.slack.com](https://join.slack.com/t/vbr-calc/shared_invite/enQtODI0MTk4NzIxNzkzLTZlYjMwYTc4MTVkOTg2ZDgyNTQxNTAxNjc2NmNkMzA2MmVjOTJkYjYzNjc1ZDJhNzg5ZWU2MzE4OTEyNmMxNGU)!

**Why doesn't the VBR Calculator do X that I need for my project Y?** The code VBR Calculator is intended as a starting point for calculating isotropic material properties that account for anelasticity of earth materials and we expect that you will need to tweak the code for your particular application in ways that we did not anticipate. If you don't know where to start in modifying the code, join our slack channel and tell us more about your project! If you are writing a proposal which would benefit from a modified VBR Calculator, get in touch to discuss a collaboration!   

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

## MIT License ##

Copyright (c) 2019-2020 Benjamin Holtzman, Christopher Havlin

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
