function TestResult = test_vbr_units()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that attach_input_metadata works as expected
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    units = SV_input_units(); % check that it runs

    VBR = struct();
    VBR.in = struct();
    VBR.in.SV = struct();
    VBR.in.SV.T_K = 1;
    VBR.in.SV.phi = 0.01;
    VBR.in.SV.P_GPa = 1;
    VBR.in.SV.not_a_field = 0;
    VBR = attach_input_metadata(VBR);
    TestResult.passed = true;
    TestResult.fail_message = '';
    if isfield(VBR.in.SV, 'units')
        if isfield(VBR.in.SV.units, "not_a_field")
            msg = "        unknown field should not be in sv_metadata";
            disp(msg)
            TestResult.passed = false;
            TestResult.fail_message = msg;
        else
            if strcmp(VBR.in.SV.units.T_K, "Kelvin") == 0
                msg = "        Incorrect units.";
                TestResult.passed = false;
                TestResult.fail_message = msg;
                disp(msg)
            end
        end
    else
        TestResult.passed = false;
        TestResult.fail_message = ' missing VBR.in.SV.units ';
    end

    % also check that the units gets attached to the VBR in a call to spine
    VBR.in.elastic.methods_list={'anharmonic'};

    % Define the Thermodynamic State
    n1 = 3;
    n2 = 5;
    VBR.in.SV.P_GPa = 2 * ones(n1,n2); % pressure [GPa]
    VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
    VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]

    VBR = VBR_spine(VBR);
    if isfield(VBR.in.SV, 'units') == 0
        msg = '         VBR.in.SV is missing units';
        TestResult.passed = false;
        TestResult.fail_message = msg;
        disp(msg)
    end
end
