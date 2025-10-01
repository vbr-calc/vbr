---
permalink: /vbrmethods/viscous/
title: "Viscous Methods"
toc: false
---

The available viscous methods are:
* `HK2003` [documentation](/vbr/vbrmethods/visc/hk2003/): Steady state olivine flow law from from Hirth and Kohlstedt 2003
* `HZK2011` [documentation](/vbr/vbrmethods/visc/hzk2011/): Steady state olivine flow law from Hansen et al., 2011
* `xfit_premelt` [documentation](/vbr/vbrmethods/visc/xfitpremelt/): Steady state flow law for pre-melting viscosity drop, Yamauchi and Takei, 2016.
* `BKHK2023` [documentation](/vbr/vbrmethods/visc/bkhk2023/): Description here!

All of the methods require the state variable structure, `VBR.in.SV` and flow law parameters are stored as substructures within `VBR.in.viscous.(method_name)`. See documenation pages for more detail.

Additionally, see the [documentation on the Small Melt Effect](/vbr/vbrmethods/visc/smallmelt/) for relevant discussion and parameters.
