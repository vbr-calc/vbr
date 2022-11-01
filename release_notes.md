# v1.0.0

This is the first series-1 release! It is backwards compatible.

## new features 

- units metadata: all output methods now contain a units structure that contains the units for each output field. You can also call `SV_input_units()` to get a structure that lists the expected units for each `VBR.in.SV` field.
- version tracking: after calling `VBR_spine`, all `VBR` structures will have a field, `VBR.version_used` with info on the VBR version that you used.

## bug fixes

(add bug fixes)
