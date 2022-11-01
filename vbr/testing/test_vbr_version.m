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
        disp('         vbr_version output missing version field')
        TestResult = false;
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
        disp('         VBR structure is missing version_used field')
        TestResult = false;
    end
end
