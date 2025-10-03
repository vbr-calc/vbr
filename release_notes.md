# v2.1.0

This release features a number of new methods (a steady state viscosity for the dislocation-based backstress model, an implementation of the Warren & Hirth 2006 grain size piezometer and a new analytical maxwell anelastic model) as well a new reference anharmonic scaling for the upper mantle. 

## New Features

### New Methods!

* Viscous backstress by @Diede-Hein in https://github.com/vbr-calc/vbr/pull/206 . [link to docs](https://vbr-calc.github.io/vbr/vbrmethods/visc/bkhk2023/).  
* Adding the Warren & Hirth (2006) Piezometer function by @Diede-Hein in https://github.com/vbr-calc/vbr/pull/221 . See the [link to docs](https://vbr-calc.github.io/vbr/vbrmethods/support/support/#piezometerwh2006) for details. 
* add analytical maxwell model by @chrishavlin in https://github.com/vbr-calc/vbr/pull/216 [link to docs](https://vbr-calc.github.io/vbr/vbrmethods/anel/maxwellanalytical/)


### Upper mantle anharmonic reference

The following contributions are all related to the new `upper_mantle` reference scaling, see the [anharmonic docs for details](https://vbr-calc.github.io/vbr/vbrmethods/el/anharmonic/#the-reference-modulus):

* some accumulated changes that are nice by @eilonzach in https://github.com/vbr-calc/vbr/pull/202
* Custom anharmonic scaling structures and preserving nested paramater structures by @chrishavlin in https://github.com/vbr-calc/vbr/pull/209 
* adding upper_mantle ref value switches, density helper functions by @chrishavlin in https://github.com/vbr-calc/vbr/pull/203

### Other new features

* add a Qinv function, use it everywhere  by @chrishavlin in https://github.com/vbr-calc/vbr/pull/205

## Changes

A couple of updates to the linearized backstress model:
* replace sig_dc_MPa with sig_MPa: its the same! by @chrishavlin in https://github.com/vbr-calc/vbr/pull/197
* backstress_linear: calculate and output values for shear modulus by @chrishavlin in https://github.com/vbr-calc/vbr/pull/199
* use shear modulus for backstress Q too by @chrishavlin in https://github.com/vbr-calc/vbr/pull/200


## Bug fixes

* BUG: fix default behavior for density_from_vbrc by @chrishavlin in https://github.com/vbr-calc/vbr/pull/224

## Documentation 

### Supporting methods 

The following changes are related to the new [supporting methods](https://vbr-calc.github.io/vbr/vbrmethods/supporting/) page, where you can check out all the functions that are available in the VBRc but until now were not obviously documented.

* Documenting extra funcs by @chrishavlin in https://github.com/vbr-calc/vbr/pull/211
* fix formatting, links on new supporting func page by @chrishavlin in https://github.com/vbr-calc/vbr/pull/212
* fix header levels on support page by @chrishavlin in https://github.com/vbr-calc/vbr/pull/213
* Add the fitting/stats functions to documented functions. by @chrishavlin in https://github.com/vbr-calc/vbr/pull/214
* fix docstring for probability_distributions by @chrishavlin in https://github.com/vbr-calc/vbr/pull/215

### Other documentation improvements 

* Linearized Backstress: add an example at lab conditions, update citation by @chrishavlin in https://github.com/vbr-calc/vbr/pull/225

## Deprecations

None 

## Infrastructure improvements

* update test_vbrcore_001: test all anelastic methods always by @chrishavlin in https://github.com/vbr-calc/vbr/pull/218

## Other changes

* Reduce code duplication in anelastic methods by @chrishavlin in https://github.com/vbr-calc/vbr/pull/217
* fix link to maxwell method by @chrishavlin in https://github.com/vbr-calc/vbr/pull/220
* fix typo in sr_tot units for viscous methods by @chrishavlin in https://github.com/vbr-calc/vbr/pull/223

## New Contributors
* @Diede-Hein made their first contributions in https://github.com/vbr-calc/vbr/pull/221 and https://github.com/vbr-calc/vbr/pull/206

**Full Changelog**: https://github.com/vbr-calc/vbr/compare/v2.0.4...v2.1.0