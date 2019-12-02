function TestResult = test_vbrcore_001()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_001()
%
% test of vbr core functionality. Just tests that all methods run
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
  disp('    **** Running test_vbrcore_001 ****')

  VBR.in.elastic.methods_list={'anharmonic';'anh_poro';'SLB2005'};
  VBR.in.viscous.methods_list={'HK2003','HZK2011'};
  VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};

  % load anharmonic parameters, adjust Gu_0_ol
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
  VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]

  %  frequencies to calculate at
  VBR.in.SV.f = logspace(-2.2,-1.3,4);

  % Define the Thermodynamic State
  n1 = 3;
  n2 = 5;
  VBR.in.SV.P_GPa = 2 * ones(n1,n2); % pressure [GPa]
  VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
  VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]
  VBR.in.SV.sig_MPa = 10 * ones(n1,n2); % differential stress [MPa]
  VBR.in.SV.phi = 0.0 * ones(n1,n2); % melt fraction
  VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,n2); % grain size [um]
  VBR.in.SV.Tsolidus_K=1200*ones(n1,n2); % solidus

  VBR_spine(VBR);

end
