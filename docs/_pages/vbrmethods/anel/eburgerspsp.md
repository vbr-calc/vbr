---
permalink: /vbrmethods/anel/eburgerspsp/
title: ''
---

# `eburgers_psp`

Extended Burgers Model with Pseudo-Period Scaling, following Jackson and Faul, 2010, Phys. Earth Planet. Inter., [DOI](https://doi.org/10.1016/j.pepi.2010.09.005). The default fitting parameters used are those of the multi-sample extended burgers fit (see below for other otpions).

## Requires

The following state variable arrays are required:

```matlab
VBR.in.SV.T_K % temperature [K]
VBR.in.SV.P_GPa % pressure [GPa]
VBR.in.SV.dg_um % grain size [um]
VBR.in.SV.sig_MPa % differential stress [MPa]
VBR.in.SV.phi % melt fraction / porosity
VBR.in.SV.rho % density in kg m<sup>-3</sup>
```
Additionally, `eburgers_psp` relies on output from the elastic methods so `anharmonic` MUST be in the `VBR.in.elastic.methods_list`. If `anh_poro` is in the methods list then `eburgers_psp` will use the unrelaxed moduli from `anh_poro` (which includes the P,T projection of `anharmonic` plus the poroelastic correction). See the section on [elastic methods](/vbr/vbrmethods/elastic/) for more details.

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Parameters

HTB, dissipation peak  


## Output  

Output is stored in `VBR.out.elastic.anharmonic`:

```matlab
>> disp(fieldnames(VBR.out.elastic.anharmonic))

{
  [1,1] = Gu % unrelaxed shear modulus at desired P,T
  [2,1] = Ku % unrelaxed bulk modulus at desired P,T
  [3,1] = Vpu % unrelaxed compressional wave velocity
  [4,1] = Vsu % unrelaxed shear wave velocity
}
```

Additionally, the unrelaxed modulus at reference conditions is returned in `VBR.out.elastic.Gu_0` as an array that is the same size as the input state variables in `VBR.in.SV`.

## Parameters

Some important parameters are
* `VBR.in.elastic.anharmonic.T_K_ref`: reference temperature in K
* `VBR.in.elastic.anharmonic.P_Pa_ref`: reference temperature in Pa
* `VBR.in.elastic.anharmonic.Gu_0_ol`: reference unrelaxed olivine modulus in GPa at reference T, P.
* `VBR.in.elastic.anharmonic.dG_dT`: temperature dependence of modulus in Pa/K (or Pa/C).
* `VBR.in.elastic.anharmonic.dG_dP`: pressure dependence of modulus, unitless.

Default values for reference temperature and pressure are surface conditions.

To view the full list of parameters,
```matlab
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
disp(VBR.in.elastic.anharmonic)
```

To set any parameter to a non-default value, simply set the field before calling `VBR_spine`:

```matlab
VBR.in.SV=struct();
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic'};

% adjust parameters
VBR.in.elastic.anharmonic.Gu_0_ol=74;

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

* How to turn/off dissipation peak
* FastBurger
