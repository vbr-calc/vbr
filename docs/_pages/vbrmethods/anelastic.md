---
permalink: /vbrmethods/anelastic/
title: 'Anelastic Methods'
toc: false
---

The anelastic methods displayed by `VBR_list_methods` currently include:

* `eburgers_psp` [documentation]({{ '/vbrmethods/anel/eburgerspsp/' | relative_url }}): Extended Burgers Model, pseudo period scaling
* `andrade_psp` [documentation]({{ '/vbrmethods/anel/andradepsp/' | relative_url }}): Andrade Model, pseudo period scaling
* `xfit_mxw` [documentation]({{ '/vbrmethods/anel/xfitmxw/' | relative_url }}): Master Curve Fit, maxwell scaling
* `xfit_premelt` [documentation]({{ '/vbrmethods/anel/xfitpremelt/' | relative_url }}): Master Curve Fit, pre-melting maxwell scaling
* `andrade_analytical` [documentation]({{ '/vbrmethods/anel/andradeanalytical/' | relative_url }}): A theoretical Andrade Model, no scaling.
* `maxwell_analytical` [documentation]({{ '/vbrmethods/anel/maxwellanalytical/' | relative_url }}): A theoretical Maxwell Model, no scaling.
* `backstress_linear` [documentation]({{ '/vbrmethods/anel/backstresslinear/' | relative_url }}): Dislocation-based dissipation using the linearized backstress of Hein et al., 2025.

A detailed theoretical description of each is provided in the full methods paper ([link](https://doi.org/10.1016/j.pepi.2020.106639)) or in the papers cited by the methods and so here, we only describe the computational aspects useful to the end user.

All of the anelastic methods require results of an elastic calculation, specifically the unrelaxed elastic moduli. If calculated, the anelastic methods may also use moduli from `VBR.out.elastic.anh_poro` and default to those from `VBR.out.elastic.anharmonic`.
