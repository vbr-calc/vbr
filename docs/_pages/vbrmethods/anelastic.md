---
permalink: /vbrmethods/anelastic/
title: "Anelastic Methods"
---

The anelastic methods displayed by `vbrListMethods` currently include:

* `eburgers_psp`: Extended Burgers Model, pseudo period scaling
* `andrade_psp`: Andrade Model, pseudo period scaling
* `xfit_mxw`: Master Curve Fit, maxwell scaling
* `xfit_premelt`: Master Curve Fit, pre-melting maxwell scaling

A detailed theoretical description of each is provided in the full VBR Manual document (IN PREP) and so here, we only describe the computational aspects useful to the end user.

All of the anelastic methods require results of an elastic calculation, specifically the unrelaxed elastic moduli. If calculated, the anelastic methods will use moduli from `VBR.out.elastic.anh_poro` and default to those from  `VBR.out.elastic.anharmonic`.

## `eburgers_psp`
Brief description.
* How to turn/off dissipation peak
* FastBurger

## `andrade_psp`
Brief description

## `xfit_mxw`
Brief description
* relies on viscous method

## `xfit_premelt`
Brief description
* relies on viscous method

## Small-melt effect
Brief description, how to turn on.
