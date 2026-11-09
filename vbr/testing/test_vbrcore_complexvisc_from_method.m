function TestResult = test_vbrcore_complexvisc_from_method()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that complex viscosity runs
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.viscous.methods_list={'HZK2011'};
    VBR.in.anelastic.methods_list={'andrade_analytical'; 'eburgers_psp'; 'andrade_psp'};

    
    % set state variables
    n1 = 5;
    VBR.in.SV.rho = 3300 * ones(n1,n1); % density [kg m^-3]
    VBR.in.SV.P_GPa = 2 * ones(n1,n1); % pressure [GPa]
    VBR.in.SV.T_K = 1473 * ones(n1,n1); % temperature [K]    
    VBR.in.SV.sig_MPa = 10 * ones(n1,n1); % differential stress [MPa]
    VBR.in.SV.phi = 0.0 * ones(n1,n1); % melt fraction
    VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,n1); % grain size [um];

    VBR.in.SV.f = logspace(-13,1,10);
    

    VBR = VBR_spine(VBR) ;

    for imeth = 1:numel(VBR.in.anelastic.methods_list)
        methname = VBR.in.anelastic.methods_list{imeth};
        [eta_star, eta_normalized, eta_app] = complex_viscosity_from_method(VBR, methname, 'anharmonic');
    end


end


