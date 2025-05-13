# v1.2.1dev

## New Features

* updates to the anharmonic calculation (PR166)[https://github.com/vbr-calc/vbr/pull/166]. Check out the updated docs page: https://vbr-calc.github.io/vbr/vbrmethods/el/anharmonic/ but here's an overview of the changes:
    * adds new flags for specifying the temperature and pressure scaling to use
    * removes the fixed poisson ratio and instead calculates a bulk modulus following the shear modulus method: there are now fields for reference bulk modulus and temperature, pressure derivatives. 
    * adds a pressure scaling from Abramson et al 1997

## Bug fixes

## Documentation 

* add VBRc workshop links to readme in [162](https://github.com/vbr-calc/vbr/pull/162)

## Deprecations

## Infrastructure improvements

* update to matlab-actions in [156](https://github.com/vbr-calc/vbr/pull/156)
