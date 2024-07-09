---
permalink: /vbrmethods/electric/gail2008_melt/
title: ''
---
# `gail2008_melt`

The `gail2008_melt` empriical relation is laboratory derived from molten carbonatites to extrapolate the conductivity of carbonatite melt. Temperature for the experiment ranged from 400m to 1000 degrees C, with pressure held at 1 atm. Magnesium bearing carbonates were not used as they are not stable at 1 atm pressure. Cited directly from Gaillard et al. (2008), "Carbonatite Melts and Electrical Conductivity in the Asthenosphere", Science, Volume 322, Issue 5906, [DOI](10.1126/science.1164446).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(400,1000,61) + 273; % temperature [K]

% add to electric methods list
VBR.in.electric.methods_list={'gail2008_melt'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.gail2008_melt.esig`, the electrical conductivity of Olivine in S/m.

