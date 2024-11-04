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
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    version = vbr_version();
    TestResult.passed = true;
    TestResult.fail_message = '';
    if isfield(version, 'version')
        TestResult.passed = true;
    else
        TestResult.passed = false;
        msg = '         vbr_version output missing version field'
        disp(msg)
        TestResult.fail_message = msg;
    end

    if isfield(version, 'is_development') == 0
        TestResult.passed = false;
        msg = '         vbr_version output missing is_development field';
        disp(msg)
        TestResult.fail_message = msg;
    elseif version.is_development == 1
        if strfind(version.version, 'dev') == 0
            TestResult.passed = false;
            msg = '         vbr_version missing dev tag';
            disp(msg)
            TestResult.fail_message = msg;
        end
    end

    % also check that the version gets attached to the VBR in a call
    VBR.in.elastic.methods_list={'anharmonic'};

    % Define the Thermodynamic State
    n1 = 3;
    n2 = 5;
    VBR.in.SV.P_GPa = 2 * ones(n1,n2); % pressure [GPa]
    VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
    VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]

    VBR = VBR_spine(VBR);
    if isfield(VBR, 'version_used') == 0
        msg = '         VBR structure is missing version_used field'
        TestResult.passed = false;
        disp(msg)
        TestResult.fail_message = msg;
    end
end
