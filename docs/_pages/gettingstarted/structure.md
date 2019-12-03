---
permalink: /gettingstarted/structure/
title: "Code Structure"
---

The code is divided into two primary subdirectories: `vbr` and `Projects`.
* `./vbr`: the inner guts of the VBR calculator. The subdirectory `./vbr/vbrCore/functions/` contains the functions in which the actual methods are coded. For example, functions beginning `Q_` are functions related to anelastic methods.
* `./Projects`: each subdirectory within this directory is an example of using the VBR Calculator in a wider "Project." These projects are self-contained codes that use the VBR Calculator in a broader context:
 * `vbr_core_examples`: scripts that simply call VBR in different ways
 * `1_LabData`: functions that call VBR for experimental conditions and materials
 * `mantle_extrap_*`: 3 directories demonstrating how to call VBR for a range of mantle conditions by (1) generating a look up table (LUT, `mantle_extrap_LUT`), (2) using an the analytical solution for half space cooling (`mantle_extrap_hspace`) and (3) using a numerical solution of half space cooling (`mantle_extrap_FM`) .
 * `LAB_fitting_bayesian` a demonstration of how one can use the VBR Calculator in a forward modeling framework to investigate seismic observations.

Note that you should write your code that uses vbr in directories outside the vbr github repository, unless you plan on submitting them to the repository (see the `DevelopmentGuide.md` if that's the case).
