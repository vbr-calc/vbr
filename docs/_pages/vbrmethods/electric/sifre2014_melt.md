---
permalink: /vbrmethods/electric/sifre2014_melt/
title: ''
---
# `sifre2014_melt`

The `sifre2014_melt` empriical relation is laboratory derived for hydrous carbonated basalts and basaltic melt. Starting materials used to obtain these mixtures were natural dolomite, a natural basalt, salt, sodium carbonate and brucite. Pressure was held constant at 3 GPa while temperatures ranged from 650 to 1500 degrees C. A Flash 2000 elemental analyser (Thermo Scientific) was used to measure the  H2O contents of samples before and after experiments. VBRc Function uses a fixed partition coefficient (D = 0.006) (Hirschmann et al, 2009) Cited directly from Sifre et al. (2014), "Electrical conductivity during incipient melting in the oceanic low-velocity zone",Nature, Issue 509, 81–85, [DOI](https://doi.org/10.1038/nature13245).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.ch2o` water content in ppm

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(650,1500,61) + 273; % temperature [K]
VBR.in.SV.ch20 = 1d4.*linspace(4,11,71); % water content [ppm]


% add to electric methods list
VBR.in.electric.methods_list={'sifre2014_melt'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.sifre2014_melt.esig`, the electrical conductivity of Olivine in S/m.
