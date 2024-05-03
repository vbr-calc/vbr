---
permalink: /vbrmethods/electric/wang2006_ol/
title: ''
---
# `wang2006_ol`

The `wang2006_ol` emprical relation is labratory derived from San Carlos Olivine powder (10-30 microns) by hydrogen-doped runs of 0.01 to 0.08 wt% H2O. Experimental pressure and temperture conditions were ~4 GPa and 873-1273 K respectively. Water contents were measured using FTIR spectroscopy with the Paterson Calibration (Patterson, 1982). Dry conduction paramters from Constable et al. 1992.  Cited directly from Wang et al. (2006), "The effect of water on electrical conductivity of olivine" Nature 443, 977-980, [DOI](https://doi.org/10.1038/nature05256).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.ch2o` water content in ppm

## Calling Procedure

```matlab
% set required state variables
clear;
VBR.in.SV.T_K = linspace(873,1273,9); % temperature [K]
VBR.in.SV.Ch2o = [0, logspace(1,4,31)]; % water content [ppm]

% add to electric methods list
VBR.in.electric.methods_list={'wang2006_ol'};

% call VBR_spine
[VBR] = VBR_spine(VBR);
```

## Output
Output is `VBR.out.electric.wang2006_ol.esig`, the electrical conductivity of olivine in S/m.
Additional outputs in this level of the struct [esig_i, esig_h, esig_p] correspond to Ionic, Polaron and Proton Conduction mechanisms respectiviely
