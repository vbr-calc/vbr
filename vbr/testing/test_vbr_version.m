function TestResult = test_vbr_version()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResult = test_vbr_version()
    %
    % test vbr_version function
    %
    % Parameters
    % ----------
    % none
    %
    % Output
    % ------
    % TestResult   True if passed, False otherwise.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('    **** Running test_vbr_version ****')
    version = vbr_version();
    if isfield(version, 'version')
        TestResult = true;
    else
        TestResult = false;
    end
end
