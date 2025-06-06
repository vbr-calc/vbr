---
permalink: /history/
title: "Release Notes"
toc: false
---

# v2.0.2dev

Current development head.

## New Features

## Bug fixes

## Documentation 

## Deprecations

## Infrastructure improvements

## Other changes

# v2.0.1

Bugfix release to improve velocity calculations from the new linearized backstress anelastic method (`backstress_model`) 

## Bug fixes
* BUG: fix the velocity calculation for backstress model by @chrishavlin in https://github.com/vbr-calc/vbr/pull/171

## Documentation 
* adding a citation from Hua et al 2025 by @chrishavlin in https://github.com/vbr-calc/vbr/pull/172

## Other changes
* remove some uses of i in for loops by @chrishavlin in https://github.com/vbr-calc/vbr/pull/174

# v2.0.0

This release of the VBRc introduces a few small but potentially breaking changes with the anharmonic calculation and also introduces a new anelastic method, the `backstress_linear` method for dislocation-based dissipation. See below for more details.

## New Features

* updates to the anharmonic calculation (PR166)[https://github.com/vbr-calc/vbr/pull/166]. Check out the updated docs page: https://vbr-calc.github.io/vbr/vbrmethods/el/anharmonic/ but here's an overview of the changes:
    * adds new flags for specifying the temperature and pressure scaling to use
    * removes the fixed poisson ratio and instead calculates a bulk modulus following the shear modulus method: there are now fields for reference bulk modulus and temperature, pressure derivatives. 
    * adds a pressure scaling from Abramson et al 1997

* new anelastic method! `backstress_linear` implements the linearized backstress model of dislocation-based dissipation from Hein et al., 2025. See the docs and new example: [docs](https://vbr-calc.github.io/vbr/vbrmethods/anel/backstresslinear/), [cookbook example](https://vbr-calc.github.io/vbr/examples/CB_017_backstress_model/). 

## Documentation 

* add VBRc workshop links to readme in [162](https://github.com/vbr-calc/vbr/pull/162)

## Infrastructure improvements

* update to matlab-actions in [156](https://github.com/vbr-calc/vbr/pull/156)


# v1.2.1

This is a maintenance release to fix an issue with filename clashes with git on mac in zsh. No changes in VBRc behavior.

## New Features

## Bug fixes
* move deprecated funcs to avoid case insensitive git clash by @chrishavlin in https://github.com/vbr-calc/vbr/pull/152

## Documentation 
* Add notes on installing specific versions @chrishavlin [#149](https://github.com/vbr-calc/vbr/pull/149)

## Deprecations

## Infrastructure improvements
* Update release instructions, fix release action @chrishavlin [#148](https://github.com/vbr-calc/vbr/pull/148)

**Full Changelog**: https://github.com/vbr-calc/vbr/compare/v1.2.0...v1.2.1

# v1.2.0

## New Features
* new method: analytical_andrade, see [documentation](https://vbr-calc.github.io/vbr/vbrmethods/anel/andradeanalytical/) for detials.
* updates to xfit_premelt: 
  * add direct melt effects from Yamauchi and Takei, 2024. The `xfit_premelt` method will use the updated parameter values when `VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1;` (default is 0, a future VBRc version will change the default to 1).
  * change default exponential melt factor (the alpha in exp(-alpha*phi) in the viscosity relationship) from 25 to 30. 
* add a `VBR_save` function for saving `VBR` structures
* add convenience function, `full_nd`, to create filled arrays

## Bug fixes
* fix for undefined behavior of pre-melt scaling at Tn == 1.0

## Deprecations
* `vbrListMethods` has been renamed to `VBR_list_methods`
* `Density_Thermal_Expansion` has been renamed to `density_thermal_expansion`
* `Density_Adiabatic_Compression` has been renamed to `density_adiabatic_compression`

## Infrastructure improvements
* add new function for printing deprecation messages, `print_func_deprecation_warning`
* add framework for handling temporary files in test suite
* add a development tag to version structure
* add weekly test runs

# v1.1.2

Minor bug fix release 

## bug fixes

- some CI fixes

# v1.1.1

Minor bug fix release 

## bug fixes

- fix for zenodo sync

# v1.1.0

## new features

- allow user-specified unrelaxed shear and bulk moduli [#63](https://github.com/vbr-calc/vbr/pull/63)
- updates to documentation [#68](https://github.com/vbr-calc/vbr/pull/68), [#57](https://github.com/vbr-calc/vbr/issues/57)

## bug fixes

no bugs

## changes

- improved error messages in test framework [#65](https://github.com/vbr-calc/vbr/issues/65)

# v1.0.1

Bug fix release.

## bug fixes

- rename `Project/bayesian_fitting/run.m` to `run_bayes.m` to avoid name conflict.

# v1.0.0

This is the first series-1 release! It is backwards compatible.

## new features

- units metadata: `VBR.in.SV` as well as all output methods now contain a units structure that contains the units for each field. You can also call `SV_input_units()` to get a structure that lists the expected units for each `VBR.in.SV` field.
- version tracking: after calling `VBR_spine`, all `VBR` structures will have a field, `VBR.version_used` with info on the VBR version that you used.
- a new function for calculating density as a function of pressure, using an interpolation of experimental measurements on F90 San Carlos olivine, `san_carlos_density_from_pressure`, following Abramson et al., JGR, 1997. Useful for
quickly calculating olivine density for a given pressure.

## bug fixes

(add bug fixes)

## changes

- some of the functions related to non-seismic material properties used in the forward
models directory have been moved and renamed. No change in usage, but it is now easier
to use those functions in a piecemeal fashion if desired. See functions in the `density`
and `thermal_properties` subdirectories within `vbr/vbrCore/fucntions/` for available
functions.

# v0.99.4

maintenance updates (testing, github CI, documentation)

## new features

- `vbr_version()` function, returns the version of the VBRc that you are using

# v <= 0.99.3

release_history.md covers v>0.99.3.


