function TestResult = test_vbrcore_011_analytical_andrade()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_010_premelt_volatiles()
%
% test for volatile behavior
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

    TestResult.passed=true;
    TestResult.fail_message = '';

    % check that the defaults run
    [VBR, fdep_size] = get_VBR();
    [VBR] = VBR_spine(VBR);
    TestResult = check_fdep_size(TestResult, VBR, fdep_size);

    % check that you can change the viscosity mechanism
    [VBR, fdep_size] = get_VBR();
    VBR.in.anelastic.andrade_analytical = Params_Anelastic('andrade_analytical');
    VBR.in.anelastic.andrade_analytical.viscosity_method_mechanism = 'gbs';
    [VBR] = VBR_spine(VBR);
    TestResult = check_fdep_size(TestResult, VBR, fdep_size);

    [VBR, fdep_size] = get_VBR();
    VBR.in.anelastic.andrade_analytical = Params_Anelastic('andrade_analytical');
    VBR.in.anelastic.andrade_analytical.viscosity_method_mechanism = 'eta_total';
    [VBR] = VBR_spine(VBR);
    TestResult = check_fdep_size(TestResult, VBR, fdep_size);

    % check that you can specify a constant eta_ss
    [VBR, fdep_size] = get_VBR();
    VBR.in.anelastic.andrade_analytical = Params_Anelastic('andrade_analytical');
    VBR.in.anelastic.andrade_analytical.viscosity_method = 'fixed';
    VBR.in.anelastic.andrade_analytical.eta_ss = 1e22;
    VBR.in.elastic.Gu_TP = full_nd(60*1e9, [fdep_size(1), fdep_size(2)]);
    VBR.in.elastic.quiet = 1;
    tau_M_expected = VBR.in.anelastic.andrade_analytical.eta_ss ./ VBR.in.elastic.Gu_TP;

    [VBR] = VBR_spine(VBR);
    TestResult = check_fdep_size(TestResult, VBR, fdep_size);
    tau_M = VBR.out.anelastic.andrade_analytical.tau_M;
    if tau_M ~= tau_M_expected
        TestResult.passed = false;
        msg = ['Maxwell time does not match expected value.', ...
               ' Found: ', num2str(tau_M), ...
               ' Expected: ', num2str(tau_M_expected)];
        TestResult.fail_message = msg;
    end
    
    % check characteristics of frequency dependence
    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.viscous.methods_list={'HZK2011'};
    VBR.in.anelastic.methods_list={'andrade_analytical'};

    VBR.in.SV.phi = 0.0;
    VBR.in.SV.T_K = 1375+273;
    VBR.in.SV.P_GPa = 2.0; % pressure [GPa]
    VBR.in.SV.dg_um= 0.01 * 1e6; % grain size [um]
    VBR.in.SV.rho = 3300; % density [kg m^-3]
    VBR.in.SV.sig_MPa =.1; % differential stress [MPa]
    VBR.in.SV.f = logspace(-12,2, 50); % [Hz]
    [VBR] = VBR_spine(VBR);

    Qinv = VBR.out.anelastic.andrade_analytical.Qinv;

    if Qinv(end) > Qinv(1)
        TestResult.passed = false;
        msg = ['Attenuation should decrease with increasing frequency but found ', ...
               'Qinv(f_max) < Qinv(f_min)'];
        TestResult.fail_message = msg;
    end

end

function TestResult = check_fdep_size(TestResult, VBR, fdep_size)
    out_size = size(VBR.out.anelastic.andrade_analytical.Qinv);
    if sum(out_size==fdep_size) ~= numel(fdep_size)
        TestResult.passed = false;
        msg = ['andrade_analytical frequency dependent variables do not ', ...
               'match the expect size. Found: ', num2str(out_size), ...
               ' Expected: ', num2str(fdep_size)];
        TestResult.fail_message = msg;
    end
end

function [VBR, fdep_size] = get_VBR()

    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.viscous.methods_list={'HZK2011'};
    VBR.in.anelastic.methods_list={'andrade_analytical'};

    sz = [5, 3];
    VBR.in.SV.phi = full_nd(0.01, sz);
    VBR.in.SV.T_K = full_nd(1350+273, sz);
    VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
    VBR.in.SV.dg_um=full_nd(0.01 * 1e6, sz); % grain size [um]
    VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = full_nd(.1, sz); % differential stress [MPa]
    VBR.in.SV.f = [0.01, .1, 1.0]; % [Hz]

    fdep_size = [sz(1), sz(2), numel(VBR.in.SV.f)]; % size of freq-dep outputs
end