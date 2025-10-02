
vbr_init
addpath(['vbr', filesep, 'testing'])
addpath(['Projects', filesep, 'vbr_core_examples'])

setenv('VBRcTesting', '1')

TestResults = run_tests();

setenv('VBRcTesting', '0')

if TestResults.failedCount > 0
    error('At least one test failed, check log.')
    quit(1)
elseif TestResults.n_tests == 0
    error('No tests collected.')
    quit(1)
end
