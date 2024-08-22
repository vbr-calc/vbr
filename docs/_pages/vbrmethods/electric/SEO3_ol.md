---
permalink: /vbrmethods/electric/SEO3_ol/
title: ''
---
# `SEO3_ol`

The `SEO3_ol` empriical relation is laboratory derived from naturally occuring Dunite (Olivine) aggregate, with a small amount of pyroxene pressent to control silica activity. The SEO3 anhydrous method has a dependency on oxygen fugacity and charge carrier mobility to calculate the conductivity of Olivine. The temperature range for the experiment cover 1000 to 1200 degrees C. Constable developed this method to rectify the short comings with the SEO2 single crystal method (Constable et al., 1992).
Cited directly from Constable (2006), "SEO3: A new model of olivine electrical conductivity", Geophysical Journal International, Volume 166, Issue 1, July 2006, Pages 435–437, [DOI](https://doi.org/10.1111/j.1365-246X.2006.03041).

## Requires:
* `VBR.in.SV.T_K` temperature in degrees K

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(1000,1200,21) + 273; % temperature [K]

% add to electric methods list
VBR.in.electric.methods_list={'SEO3_ol'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output
Output is `VBR.out.electric.SEO3_ol.esig`, the electrical conductivity of Olivine in S/m.
