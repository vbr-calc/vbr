---
layout: archive
title: "The Very Broadband Rheology Calculator"
sidebar:
  nav: "docs"
---

The **Very Broadband Rheology (VBR)** Calculator is a **very** flexible framework for calculating mechanical properties (e.g., viscosity, shear wave velocity, intrinsic attenuation) across the entire band of geophysical time scales from seismic wave propagation to convection, as functions of input thermodynamic state variables (e.g., temperature, pressure, melt fraction, grain size) using a wide range of experimentally derived constitutive models.

!['VBRsimpleflowchart'](/vbr/assets/images/VBRsimpleFlowchart.png){:class="img-responsive"}

The code is free to use and expand. Read more about the background of the VBR Calculator [here](/vbr/about/), or dive into using it with the [installation](/vbr/gettingstarted/installation/) and [quick start](/vbr/gettingstarted/) guides or [example usage](/vbr/examples/).

For information on the experimental Python wrapper, check out [pyVBRc](https://github.com/vbr-calc/pyVBRc).

### Citing

If using the VBRc in your research, please cite the primary VBRc "methods paper":

Havlin, C., Holtzman, B.K. and Hopper, E., 2021. Inference of thermodynamic state in the asthenosphere from anelastic properties, with applications to North American upper mantle. Physics of the Earth and Planetary Interiors, 314, p.106639, [https://doi.org/10.1016/j.pepi.2020.106639](https://doi.org/10.1016/j.pepi.2020.106639).

Additionally, you're welcome to cite the software DOI directly if you would like to point your readers directly to the software (but please also cite the methods paper above):

[![DOI](https://zenodo.org/badge/225459902.svg)](https://zenodo.org/badge/latestdoi/225459902)

We also encourage you to cite the underlying primary sources that developed the scaling methods implemented by the VBRc, particularly if comparing results from different methods. The relevant sources are in the above methods paper, but many are also documented [in the code itself](https://github.com/vbr-calc/vbr#how-to-cite).

### Funding

Over the years, support for development of the VBR Calculator has been provided by a number of public funding sources, including:

* 2022: NSF FRES [2218542](https://www.nsf.gov/awardsearch/show-award?AWD_ID=2218542), in particular [2217616](https://www.nsf.gov/awardsearch/show-award?AWD_ID=2217616), Dalton, Lau, Chanard, Hansen, Havlin, Turk, Holtzman & Eilon (see also [istrum.github.io](https://istrum.github.io))
* 2017: [NSF EAR Earthscope 1736165](https://www.nsf.gov/awardsearch/show-award/?AWD_ID=1736165), Holtzman & Havlin
* 2013: [NSF EAR Geophysics 1315254](https://www.nsf.gov/awardsearch/show-award?AWD_ID=1315254), Davis, Holtzman & Nettles
* 2011: [NSF EAR Geophysics (CAREER) 1056332](https://www.nsf.gov/awardsearch/show-award?AWD_ID=1056332), Holtzman
