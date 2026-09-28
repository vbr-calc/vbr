---
permalink: /vbrmethods/viscous/
title: "Viscous Methods"
toc: false
---

The available viscous methods are:
* `HK2003` [documentation]({{ '/vbrmethods/visc/hk2003/' | relative_url }}): Steady state olivine flow law from from Hirth and Kohlstedt 2003
* `HZK2011` [documentation]({{ '/vbrmethods/visc/hzk2011/' | relative_url }}): Steady state olivine flow law from Hansen et al., 2011
* `xfit_premelt` [documentation]({{ '/vbrmethods/visc/xfitpremelt/' | relative_url }}): Steady state flow law for pre-melting viscosity drop, Yamauchi and Takei, 2016.
* `BKHK2023` [documentation]({{ '/vbrmethods/visc/bkhk2023/' | relative_url }}): steady state solution for the dislocation backstress model of Breithaupt et al., 2023.

All of the methods require the state variable structure, `VBR.in.SV` and flow law parameters are stored as substructures within `VBR.in.viscous.(method_name)`. See documenation pages for more detail.

Additionally, see the [documentation on the Small Melt Effect]({{ '/vbrmethods/visc/smallmelt/' | relative_url }}) for relevant discussion and parameters.
