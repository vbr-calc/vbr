---
permalink: /vbrmethods/el/anhporo/
title: ''
---

# `anh_poro`

The poro-elastic scaling applies a correction for poro-elasticity on top of the anharmonic scaling. The scaling method follows Appendix A of Takei, 2002, "Effect of pore geometry on VP/VS: From equilibrium geometry to crack", JGR Solid Earth, [DOI](https://doi.org/10.1029/2001JB000522).

## Requires
* `VBR.out.elastic.anharmonic` result of anharmonic calculation.
* `VBR.in.SV.phi` melt fraction or porosity (volume fraction)

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]
VBR.in.SV.phi = 0.01 * ones(size(VBR.in.SV.T_K)); % melt fraction / porosity

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic','anh_poro'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is stored in `VBR.out.elastic.anh_poro`:

```matlab
>> disp(fieldnames(VBR.out.elastic.anharmonic))

{
  [1,1] = Gu % unrelaxed shear modulus at desired P,T,phi
  [2,1] = Ku % unrelaxed bulk modulus at desired P,T,phi
  [3,1] = Vpu % unrelaxed compressional wave velocity
  [4,1] = Vsu % unrelaxed shear wave velocity
}
```

## Examples

See `Projects/vbr_core_examples/CB_009_anhporo.m`:

!['CB_009_anhporo'](/vbr/assets/images/CBanhporo.png){:class="img-responsive"}
