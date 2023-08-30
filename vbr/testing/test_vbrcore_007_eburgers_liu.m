function TestResult = test_vbrcore_007_eburgers_liu()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_007_eburgers_liu()
%
% test the liu et al water scaling
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult=true;
    disp('    **** Running test_vbrcore_007_eburgers_liu ****')

    % run liu et al water scaling, set background
    % dissippation to 0 and check that the peak is where
    % it is supposed to be.

    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.anelastic.methods_list={'eburgers_psp'};
    VBR.in.anelastic.eburgers_psp = Params_Anelastic('eburgers_psp');
    VBR.in.anelastic.eburgers_psp.eBurgerFit='liu_water_2023';
    VBR.in.anelastic.eburgers_psp.liu_water_2023.DeltaB = 0.0;

    tau = logspace(-1, 4, 100);
    VBR.in.SV.f = 1./tau;
    T_K = [1223, 1273, 1323, 1373];
    Ch2o_ppm = [9, 77, 143];

    [VBR.in.SV.T_K, VBR.in.SV.Ch2o] = meshgrid(T_K, Ch2o_ppm);
    sz = size(VBR.in.SV.T_K);
    VBR.in.SV.dg_um = 76 * ones(sz); % close to measured values in experiments
    VBR.in.SV.P_GPa = 3 * ones(sz); % fixed experimetnal condition
    VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
    VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

    %% Call VBR_spine again %%
    [VBR] = VBR_spine(VBR) ;

    Qinv = VBR.out.anelastic.eburgers_psp.Qinv(1,1,:);
    Qinvmax = max(Qinv(:));
    tau_peak_actual = tau(Qinv==Qinvmax);

    % note: the expected peak location in Qinv is not the tau_PR, the
    % actual dissipation peak location, because Qinv is J1/J2, which
    % include the maxwell term and integrals of the peak. so the
    % final peak shifts a bit. the following number was found
    % empirically.  
    tau_peak = 3.2745;

    if abs(tau_peak - tau_peak_actual) > 0.001
        TestResult = false;
    end


end
