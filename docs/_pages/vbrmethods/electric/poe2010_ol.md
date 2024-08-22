---
permalink: /vbrmethods/electric/poe2010_ol/
title: ''
---
# `poe2010_ol`

The `poe2010_ol` empriical relation is laboratory derived from hydrogen doped and undoped runs of single crystal San Carlos Olivine (Fo_90). Anhydrous runs undertaken at temperature and pressure conditions of 850 to 1436 degrees C at 8 GPa. The hydrated samples ran at identical pressures but lower temperatures (<=700) as to minimize dehydratrion. Experiments conducted for anisotropic crystal orientations for water contents up to ~2000 wt ppm determined by FTIR Spectroscopy by the Bell Calibration (Bell, 2003). Cited directly from Poe et al. (2010), "Electrical conductivity anisotropy of dry and hydrous olivine at 8 GPa", Physics of the Earth and Planetary Interiors, Volume 181, Issues 3–4, [DOI](https://doi.org/10.1016/j.pepi.2010.05.003).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.ch2o` water content in ppm

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(850,1450,61) + 273; % temperature [K]
VBR.in.SV.ch20 = linspace(0,2200,23) + 273; % water content [ppm]


% add to electric methods list
VBR.in.electric.methods_list={'poe2010_ol'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.poe2010_ol.esig`, the electrical conductivity of Olivine in S/m.
Additional outputs in this level of the struct [esig_H, esig_A] correspond to hydrous and anhydrous conduction mechanisms respectiviely
