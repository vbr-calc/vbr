
vbr_init
addpath('vbr/testing')

TestResults = run_tests();

if TestResults.failedCount > 0
    error('At least one test failed, check log.')
elseif TestResults.n_tests == 0
    error('No tests collected.')
end
