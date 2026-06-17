# v2.1.1

Bux fix release with fixes for the new viscous backstress (BKHK2023) method

## Bug fixes

* Update sr_visc_calc_BKHK2023.m by @Diede-Hein in https://github.com/vbr-calc/vbr/pull/229
* BKHK2023 Viscosity: set NaN for nonpositive taylor stress, warn once by @chrishavlin in https://github.com/vbr-calc/vbr/pull/242
* check for anharmonic method for BKHK2023 viscous method by @chrishavlin in https://github.com/vbr-calc/vbr/pull/243

## Documentation

* update funding section by @chrishavlin in https://github.com/vbr-calc/vbr/pull/231
* add Dannberg, Sim citations to related publications by @chrishavlin in https://github.com/vbr-calc/vbr/pull/230

## Infrastructure improvements

* bump checkout, matlab runner versions by @chrishavlin in https://github.com/vbr-calc/vbr/pull/244
