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
