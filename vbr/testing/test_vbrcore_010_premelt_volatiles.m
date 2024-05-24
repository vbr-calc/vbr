function TestResult = test_vbrcore_010_premelt_volatiles()
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

    % the melt-free viscosity should match between the two cases (one with water,
    % one without) because the solidus is not being changed between them. This is
    % a math check more than a physical check.
    VBR = get_VBR(0.0);
    [VBR] = VBR_spine(VBR);
    VBR_1 = get_VBR(1.0);
    [VBR_1] = VBR_spine(VBR_1);

    eta = VBR.out.viscous.xfit_premelt.diff.eta_meltfree;
    eta_1 = VBR_1.out.viscous.xfit_premelt.diff.eta_meltfree;

    if sum(abs(eta -eta_1)) > 0
        TestResult.passed=false;
        TestResult.fail_message = 'the viscosity values do not match!';
    end

    Q = VBR.out.anelastic.xfit_premelt.Q;
    Q_1 = VBR_1.out.anelastic.xfit_premelt.Q;
    if sum(abs(Q - Q_1)) > 0
        TestResult.passed=false;
        TestResult.fail_message = 'the Q values do not match!';
    end

    etaHK = VBR.out.viscous.HK2003.diff.eta;
    etaHK_1 = VBR_1.out.viscous.HK2003.diff.eta;
    if sum(etaHK > etaHK_1) > 0
        % note: etaHK_1 (the case with water) should be < etaHK in all cases
        TestResult.passed=false;
        TestResult.fail_message = 'HK2003 eta with water should be weaker.';
    end
end

function VBR = get_VBR(water_val)

    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.viscous.methods_list={'xfit_premelt'; 'HK2003'};
    VBR.in.anelastic.methods_list={'xfit_premelt'};

    VBR.in.viscous.xfit_premelt = Params_Viscous('xfit_premelt');
    VBR.in.viscous.xfit_premelt.eta_melt_free_method = 'HK2003';

    sz = [5, 1];
    VBR.in.SV.phi = full_nd(0.01, sz);
    VBR.in.SV.Ch2o = full_nd(water_val, sz);
    VBR.in.SV.T_K = full_nd(1350+273, sz);
    VBR.in.SV.Tsolidus_K = full_nd(1300+273., sz);
    VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
    VBR.in.SV.dg_um=full_nd(0.01 * 1e6, sz); % grain size [um]
    VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = full_nd(.1, sz); % differential stress [MPa]
    VBR.in.SV.f = 10.; % 1 Hz
end