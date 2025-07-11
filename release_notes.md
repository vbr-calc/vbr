# v2.0.2dev

A bug fix release to address issues with calculation of elastic moduli when using the chi-mixing for moduli that were introduced in VBRc version 2.0.0 (prior versions were unaffected). This work also includes a bunch of updates to testing infrastructure to automatically run the cookbook examples in the test suite. 

## Bug fixes

* Bug: in the calculation of elastic moduli for crustal values that gets used in the chi-mixing for anharmonic properties (units of moduli were wrong) [#181](https://github.com/vbr-calc/vbr/pull/181) by @chrishavlin

## Documentation 

* All cookbook examples in `Projects/vbr_core_examples` are now functions and their formatting has been updated slightly [#181](https://github.com/vbr-calc/vbr/pull/181) by @chrishavlin

## Infrastructure improvements

* [#181](https://github.com/vbr-calc/vbr/pull/181) added an automated test that runs all cookbook examples, which included some updates to testing and support functions:
    * a new environment variable `VBRcTesting` that gets set to `'1'` when tests are running in order to suppress plotting in the cookbook examples
    * some minimal field value validation for many fields in the output VBR structure
    * a new function, `get_nested_field_from_struct` let's you get a nested structure field by supplying a cell string "path" to the field: `Q = get_nested_field_from_struct(VBR, {'out'; 'anelastic'; 'andrade_psp'; 'Q'})`. 
    * a new function, `concat_cell_strs` concatenates all the strings in a cell array of strings, `concat_cell_strs({'hello'; 'there'}, '_')` will result in `hello_there`. 

