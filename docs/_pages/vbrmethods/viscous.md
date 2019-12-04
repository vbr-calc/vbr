---
permalink: /vbrmethods/viscous/
title: "Viscous Methods"
---

The available viscous methods are:
* `HK2003`: Steady state olivine flow law from from Hirth and Kohlstedt 2003
* `HZK2011`: Steady state olivine flow law from Hansen et al., 2011
* `xfit_premelt`: Steady state flow law for pre-melting viscosity drop, Yamauchi and Takei, 2016.

All of the methods require the state variable structure, `VBR.in.SV`, with the following fields:


Flow law parameters are stored as substructures within `VBR.in.viscous.(method_name)`.

## `HK2003` and `HZK2011`

`HK2003` and `HZK2011` behave similarly. To set flow law parameters:

## `xfit_premelt`
By default, this method uses flow law paramters (reference viscosity, activation energy, etc.) from a fit to the upper mantle.

The parameter, `VBR.in.viscous.xfit_premelt` can be set to `HK2003` or `HZK2011`, in which case the melt-free viscosity is calculated using one of these methods. The near-solidus pre-melting effect is then multiplied on. More explicitly:


## Small melt effect
describe how to turn on/off
