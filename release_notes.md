# v1.1.2dev

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
