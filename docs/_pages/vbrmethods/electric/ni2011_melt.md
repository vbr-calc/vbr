---
permalink: /vbrmethods/electric/ni2011_melt/
title: ''
---
# `ni2011_melt`

The `ni2011_melt` empriical relation is laboratory derived from electrical conductivity studies of hydrous and anhydrous basaltic melts. The water content ranged from  Impedance spectra were collected at temperature condition of 1,473–1,923 degrees K and 2 GPa respectively. Water contents ranged from 0.02 - 6.3 wt% H2O and were verified using the Karl Fischer Titration (KFT) method and FTIR spectroscopy. Cited directly from Ni et al. (2011), "Electrical conductivity of hydrous basaltic melts: implications for partial melting in the upper mantle", Contrib Mineral Petrol 162, 637–650 (2011), [DOI](https://doi.org/10.1007/s00410-011-0617-4).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.ch2o` water content in ppm

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(1200,1650,46) + 273; % temperature [K]
VBR.in.SV.ch20 = 1d4.*linspace(0,6,61); % water content [ppm]


% add to electric methods list
VBR.in.electric.methods_list={'ni2011_melt'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.ni2011_melt.esig`, the electrical conductivity of Olivine in S/m.
