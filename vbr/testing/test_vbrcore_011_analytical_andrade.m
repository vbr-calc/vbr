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

    % check that you can specify a constant eta_ss

    % check characteristics of frequency dependence 
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
    VBR.in.SV.Ch2o = full_nd(0.00, sz);
    VBR.in.SV.T_K = full_nd(1350+273, sz);
    VBR.in.SV.Tsolidus_K = full_nd(1300+273., sz);
    VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
    VBR.in.SV.dg_um=full_nd(0.01 * 1e6, sz); % grain size [um]
    VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = full_nd(.1, sz); % differential stress [MPa]
    VBR.in.SV.f = [0.01, .1, 1.0]; % [Hz]

    fdep_size = [sz(1), sz(2), numel(VBR.in.SV.f)]; % size of freq-dep outputs
end