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

    isOctave = is_octave();

    if isOctave
        TestResult = false;
        disp("   This test is MATLAB only, but Octave is running it..")
    end


end
