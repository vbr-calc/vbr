function TestResult = test_vbrcore_008_premelt_Tn_1()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_008_premelt_Tn_1()
%
% test for undefined behavior at Tn == 1.0
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

  %% write method list %%
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.anelastic.methods_list={'xfit_premelt'};
  VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 0;

  % load anharmonic parameters, adjust Gu_0_ol and derivatives to match YT2016
  VBR.in.elastic.anharmonic.Gu_0_ol=72.45; %[GPa]
  VBR.in.elastic.anharmonic.dG_dT = -10.94*1e6; % Pa/C    (equivalent ot Pa/K)
  VBR.in.elastic.anharmonic.dG_dP = 1.987; % GPa / GPa

  %% Define the Thermodynamic State %%
  VBR.in.SV.T_K=1200:25:1500;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  VBR.in.SV.Tsolidus_K = VBR.in.SV.T_K;
  sz=size(VBR.in.SV.T_K); % temperature [K]
  VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
  VBR.in.SV.dg_um=full_nd(0.01 * 1e6, sz); % grain size [um]
  VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = full_nd(.1, sz); % differential stress [MPa]
  VBR.in.SV.phi = full_nd(0.0, sz);
  VBR.in.SV.f = 1 ; % 1 Hz

  [VBR] = VBR_spine(VBR);

  if sum(VBR.out.viscous.xfit_premelt.diff.eta == 0.0) > 0
    msg = 'xfit_premelt.diff.eta contains 0.0 values';
    TestResult.passed = false;
    TestResult.fail_message = msg;
  end

end


