function TestResult = test_matlab_only_test_trigger()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResult = test_matlab_only_test_trigger()
    %
    % this tests should not run on octave
    %
    % Parameters
    % ----------
    % none
    %
    % Output
    % ------
    % TestResult   True if passed, False otherwise.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult=true;
    disp('    **** Running test_matlab_only_test_trigger ****')

    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    if isOctave
        TestResult = false;
        disp("   This test is MATLAB only, but you Octave is running it..")
    end


end
