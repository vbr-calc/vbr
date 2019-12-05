---
permalink: /vbrmethods/visc/smallmelt/
title: ''
toc: false
---

# Small Melt Effect

The small melt effect is the parametrization of the melt-correction factor of Holtzman, B. K. (2016), "Questions on the existence, persistence, and mechanical effects of a very small melt fraction in the asthenosphere", Geochem. Geophys. Geosyst., 17, 470– 484, [DOI](https://doi.org/10.1002/2015GC006102).

By default, the melt-correction factor is turned off by the `VBR.in.GlobalSettings.melt_enhancement` flag. To turn it on, set `VBR.in.GlobalSettings.melt_enhancement=1` before calling `VBR_spine()`. The strength of the melt enhancement is controlled by `phi_c` and `x_phi_c` in the flow law parameter structures (e.g., `VBR.in.SV.HZK2011.diff.phi_c`) but those fields are only used when `VBR.in.GlobalSettings.melt_enhancement=1`.
