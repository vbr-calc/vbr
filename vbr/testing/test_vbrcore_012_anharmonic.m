function TestResult = test_vbrcore_012_anharmonic()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that all the anharmonic scaling options run
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
    VBR.in.anelastic.methods_list={'xfit_premelt'};

    %  frequencies to calculate at
    VBR.in.SV.f = [0.01,0.1];

    % Define the Thermodynamic State
    VBR.in.SV.T_K=linspace(500,1400,10)+273;
    sz=size(VBR.in.SV.T_K);
    VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
    VBR.in.SV.T_K = 1473 * ones(sz); % temperature [K]
    VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
    VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]
    VBR.in.SV.Tsolidus_K=1200*ones(sz); % solidus
    VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

    anh_params = Params_Elastic('anharmonic'); 

    p_scalings = anh_params.available_pressure_scaling; 
    t_scalings = anh_params.available_temperature_scaling; 

    for ip = 1:numel(p_scalings)
        for it = 1:numel(t_scalings)
            VBRnew = VBR; 
            VBRnew.in.elastic.anharmonic.temperature_scaling = t_scalings{it}; 
            VBRnew.in.elastic.anharmonic.pressure_scaling = p_scalings{ip}; 
            VBRnew = VBR_spine(VBRnew);
        end 
    end 


end
