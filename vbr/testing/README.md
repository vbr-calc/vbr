## testing

This directory contains test scripts that should be run periodically when making changes.

`run_tests.m` is the main driver. The default is to run all `.m` files in this directory
that start with `test_`.

When creating new code functionality, add a test function here.

### running tests

To run all tests:

```
cd vbr/testing
test_results=run_tests;
```

The code will execute all the `.m` files. If any fail to run, a warning message will print to screen. After the tests run, if there are any failed tests you should run those tests individually to see the full matlab error. The output variable `test_results` is a structure with each test function as a field with each set to 0 or 1 to indicate failure or success. The `run_test` function includes an optional input argument `test_file_string` that is used to match the test function names, e.g., `run_test(test_file_string)`. So if you want to only run a subset of tests, provide a common string (e.g., `fm_plates` to run the forward model tests only).

Example output containing a failed test:

```
Running tests for test_file_string: vbrcore

initializing with vbr_version: VBR_v0p95
VBR calculator initialized
Starting full_test

    **** Running test_000_vbrcore ****
    test_000_vbrcore failed :(
    please run test_000_vbrcore() and debug.

Testing complete.

Displaying failed test functions. Please run each one and debug:
    test_000_vbrcore
```

You would then need to run `test_000_vbrcore()` to debug the problem.

### adding tests

To write a new test, it's easiest to copy one of the existing tests to a new file and
modify the function name, docstring and messaging. The most important point is that the
new test function **must** return a boolean value that is `true` if the test ran as expected
and is `false` if your function did not behave as expected. If your test simply checks
whether or not some code runs without error, then your function should always return
`true` as any errors will be caught during execution.

If you are adding a test that is not compatible with octave, add the test function name
to the test configuration in the `get_config.m` file. 
