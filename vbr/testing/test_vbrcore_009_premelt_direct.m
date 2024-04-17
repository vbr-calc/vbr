function TestResult = test_vbrcore_009_premelt_direct()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_009_premelt_direct()
%
% test for when include_direct_melt_effect == 1
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
  VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1;

  % load anharmonic parameters, adjust Gu_0_ol and derivatives to match YT2016
  VBR.in.elastic.anharmonic.Gu_0_ol=72.45; %[GPa]
  VBR.in.elastic.anharmonic.dG_dT = -10.94*1e6; % Pa/C    (equivalent ot Pa/K)
  VBR.in.elastic.anharmonic.dG_dP = 1.987; % GPa / GPa

  %% Define the Thermodynamic State %%
  VBR.in.SV.phi = logspace(-8,log10(0.05), 10);

  sz=size(VBR.in.SV.phi); % temperature [K]
  VBR.in.SV.T_K = full_nd(1350+273, sz);
  VBR.in.SV.Tsolidus_K = full_nd(1300+273., sz);
  VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
  VBR.in.SV.dg_um=full_nd(0.01 * 1e6, sz); % grain size [um]
  VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = full_nd(.1, sz); % differential stress [MPa]

  VBR.in.SV.f = 10.; % 1 Hz

  [VBR] = VBR_spine(VBR);

  Qinv = VBR.out.anelastic.xfit_premelt.Qinv;
  phi = VBR.in.SV.phi;
  dQdphi = (Qinv(2:end) - Qinv(1:end-1))./ (phi(2:end) - phi(1:end-1));
  if sum(dQdphi<0) > 0
        TestResult.passed=false;
        TestResult.fail_message = 'Increasing melt fraction should increase Qinv.';
  end
end


