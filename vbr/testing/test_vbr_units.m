function TestResult = test_vbr_units()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that attach_input_metadata works as expected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp('    **** Running test_vbr_units ****')
    
    units = SV_input_units(); % check that it runs
    
    VBR = struct();
    VBR.in = struct();
    VBR.in.SV = struct();
    VBR.in.SV.T_K = 1; 
    VBR.in.SV.phi = 0.01; 
    VBR.in.SV.P_GPa = 1;
    VBR.in.SV.not_a_field = 0;
    VBR = attach_input_metadata(VBR);
    TestResult = true;
    if isfield(VBR.in.SV, 'units')
        if isfield(VBR.in.SV.units, "not_a_field")
            disp("        unknown field should not be in sv_metadata")
            TestResult = false;
        else
            if strcmp(VBR.in.SV.units.T_K, "Kelvin") == 0 
                disp("        Incorrect units.")
                TestResult = false;
            end
        end 
    else
        TestResult = false;
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
        disp('         VBR.in.SV is missing units')
        TestResult = false;
    end
end 
