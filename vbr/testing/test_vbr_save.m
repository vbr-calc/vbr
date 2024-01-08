function TestResult = test_vbr_save()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that the save function works
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

    VBR = VBR_spine(VBR);
    test_config = get_config();
    save_dir = test_config.vbr_test_data_dir;

    save_file = fullfile(save_dir, "test_vbr_save.mat");
    VBR_save(VBR, save_file)
    VBR_loaded = load(save_file);
    if sum(VBR.in.SV.T_K == VBR_loaded.in.SV.T_K) ~= sz
        msg = ['         saved VBR structure does not match'];
        TestResult.passed = false;
        TestResult.fail_message = msg;
        disp(msg)
    end

    save_file = fullfile(save_dir, "test_vbr_save_no_SV.mat");
    VBR_save(VBR, save_file, 1)
    VBR_loaded = load(save_file);
    if isfield(VBR_loaded.in, 'SV')
        msg = ['         saved VBR structure should not contain SV when excluded.'];
        TestResult.passed = false;
        TestResult.fail_message = msg;
        disp(msg)
    end

end
