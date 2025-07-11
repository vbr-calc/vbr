function TestResult = test_matlab_only_test_trigger()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResult = test_matlab_only_test_trigger()
    %
    % this test should not run on octave
    %
    % Parameters
    % ----------
    % none
    %
    % Output
    % ------
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed =true;
    TestResult.fail_message = '';    

    isOctave = is_octave();

    if isOctave
        TestResult.passed = false;
        msg = "   This test is MATLAB only, but Octave is running it...";
        disp(msg);
        TestResult.fail_message = msg;
    end


end
