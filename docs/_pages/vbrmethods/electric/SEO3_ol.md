---
permalink: /vbrmethods/electric/yosh2009_ol/
title: ''
---
# `yosh2009_ol`

The `yosh2009_ol` emprical relation is labratory derived from San Carlos Olivine (M_0.91, Fe_0.09) powder (<1 micron) by hydrogen-doped and undoped runs. Initial water content for selected crystal were less than  <0.005 wt% H2O. Experimental pressure and temperture conditions were 10 GPa and 1373-1623 K respectively. Post experimental analysis of hydrogen-doped samples yielded a Mg number of 92.5. Water contents were measured using FTIR spectroscopy with the Paterson Calibration (Patterson, 1982). Cited directly from Yoshino et al. (2009), "The effect of water on the electrical conductivity of olivine aggregates and its implications for the electrical structure of the upper mantle" EPSL 288.1-2, [DOI](https://doi.org/10.1016/j.epsl.2009.09.032).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.ch2o` water content in ppm

## Calling Procedure

```matlab
% set required state variables
clear;
VBR.in.SV.T_K = linspace(500,2000,31); % temperature [K]
VBR.in.SV.Ch2o = [0, logspace(0,4,41)]; % water content [ppm]

% add to electric methods list
VBR.in.electric.methods_list={'yosh2009_ol'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.yosh2009_ol.esig`, the electrical conductivity of Olivine in S/m.
Additional outputs in this level of the struct [esig_i, esig_h, esig_p] correspond to Ionic, Polaron and Proton Conduction mechanisms respectiviely
