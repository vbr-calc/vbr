# v1.1.3

## New Features
* updates to xfit_premelt: 
  * add direct melt effects from Yamauchi and Takei, 2024. The `xfit_premelt` method will use the updated parameter values when `VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1;` (default is 0, a future VBRc version will change the default to 1).
  * change default exponential melt factor (the alpha in exp(-alpha*phi) in the viscosity relationship) from 25 to 30.
* add complex viscosity calculation for anelastic methods. Either set `VBR.in.GlobalSettings.anelastic.include_complex_viscosity = 1;` before calling `VBR_spine()` or call `VBR = complex_viscosity_VBR(VBR, method)` to calculate independently after `VBR_spine` for a single anelastic method **or** use the general `complex_viscosity` function. 
* add a `VBR_save` function for saving `VBR` structures 
* add framework for handling temporary files in test suite
* add convenience function, `full_nd`, to create filled arrays

## Bug fix
* fix for undefined behavior of pre-melt scaling at Tn == 1.0