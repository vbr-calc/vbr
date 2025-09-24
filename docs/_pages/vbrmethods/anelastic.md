---
permalink: /vbrmethods/anelastic/
title: 'Anelastic Methods'
toc: false
---

The anelastic methods displayed by `VBR_list_methods` currently include:

* `eburgers_psp` [documentation](/vbr/vbrmethods/anel/eburgerspsp/): Extended Burgers Model, pseudo period scaling
* `andrade_psp` [documentation](/vbr/vbrmethods/anel/andradepsp/): Andrade Model, pseudo period scaling
* `xfit_mxw` [documentation](/vbr/vbrmethods/anel/xfitmxw/): Master Curve Fit, maxwell scaling
* `xfit_premelt` [documentation](/vbr/vbrmethods/anel/xfitpremelt/): Master Curve Fit, pre-melting maxwell scaling
* `andrade_analytical` [documentation](/vbr/vbrmethods/anel/andradeanalytical/): A theoretical Andrade Model, no scaling.
* `maxwell_analytical` [documentation](/vbr/vbrmethods/anel/maxwellalytical/): A theoretical Maxwell Model, no scaling.
* `backstress_linear` [documentation](/vbr/vbrmethods/anel/backstresslinear/): Dislocation-based dissipation using the linearized backstress of Hein et al., 2025.

A detailed theoretical description of each is provided in the full methods paper ([link](https://doi.org/10.1016/j.pepi.2020.106639)) or in the papers cited by the methods and so here, we only describe the computational aspects useful to the end user.

All of the anelastic methods require results of an elastic calculation, specifically the unrelaxed elastic moduli. If calculated, the anelastic methods may also use moduli from `VBR.out.elastic.anh_poro` and default to those from `VBR.out.elastic.anharmonic`.
