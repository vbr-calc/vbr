---
permalink: /vbrmethods/anelastic/
title: "Anelastic Methods"
toc: false
---

The anelastic methods displayed by `vbrListMethods` currently include:

* `eburgers_psp` [documentation](/vbr/vbrmethods/anel/eburgerspsp/): Extended Burgers Model, pseudo period scaling
* `andrade_psp` [documentation](/vbr/vbrmethods/anel/andradepsp/): Andrade Model, pseudo period scaling
* `xfit_mxw` [documentation](/vbr/vbrmethods/anel/xfitmxw/): Master Curve Fit, maxwell scaling
* `xfit_premelt` [documentation](/vbr/vbrmethods/anel/xfitpremelt/): Master Curve Fit, pre-melting maxwell scaling

A detailed theoretical description of each is provided in the full VBR Manual document (IN PREP) and so here, we only describe the computational aspects useful to the end user.

All of the anelastic methods require results of an elastic calculation, specifically the unrelaxed elastic moduli. If calculated, the anelastic methods will use moduli from `VBR.out.elastic.anh_poro` and default to those from  `VBR.out.elastic.anharmonic`.
