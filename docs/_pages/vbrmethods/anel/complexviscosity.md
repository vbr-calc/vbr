---
permalink: /vbrmethods/anel/complexviscosity/
title: ''
---


# Complex viscosity

The complex viscosity is analogous to the complex modulus cast to viscosity, see the references below for more background. 

There are 2 functions for calculating complex viscosity from VBRc outputs: 

* `complex_viscosity` ([full docstring](/vbr/vbrmethods/support/support/#complex_viscosity)): calculate complex viscosity from complex compliance.
* `complex_viscosity_from_method` ([full docstring](/vbr/vbrmethods/support/support/#complex_viscosity_from_method)): calculate complex viscosity from the VBR output structure.

See the [example](/vbr/examples/CB_016_complex_viscosity/) for usage. 

## References

* Lau, Holtzman and Havlin, "Toward a Self-Consistent Characterization of Lithospheric Plates Using Full-Spectrum Viscoelasticity", AGU Advances, 2020 https://doi.org/10.1029/2020AV000205 
* Lau, Austermann, Holtzman, Havlin, Lloyd, Book, Hopper, "Frequency Dependent Mantle Viscoelasticity via the Complex Viscosity: Cases From Antarctica", JGR, 2021 https://doi.org/10.1029/2021JB022622 
* Lau & Holtzman, “Measures of dissipation in viscoelastic media” extended: Toward continuous characterization across very broad geophysical time scales", GRL, 2019 https://doi.org/10.1029/2019GL083529