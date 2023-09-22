function TestResult = test_vbrcore_003()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_003()
%
% runs eburgers with slow and fast burgers, compares the two
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

  TestResult.passed =true;
  TestResult.fail_message = '';

  VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
  VBR.in.anelastic.methods_list={'eburgers_psp'};

  %  frequencies to calculate at
  VBR.in.SV.f = [0.01,0.1];

  % Define the Thermodynamic State
  VBR.in.SV.T_K=linspace(500,1400,100)+273;
  sz=size(VBR.in.SV.T_K);
  n1 = 3;
  n2 = 5;
  VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
  VBR.in.SV.T_K = 1473 * ones(sz); % temperature [K]
  VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
  VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]
  VBR.in.SV.Tsolidus_K=1200*ones(sz); % solidus
  VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction
  VBR.in.SV.phi(VBR.in.SV.T_K>=VBR.in.SV.Tsolidus_K)=0.01;

  VBRslow=VBR_spine(VBR);

  VBR.in.anelastic.eburgers_psp.method='FastBurger';
  VBRfast=VBR_spine(VBR);

  slowV=VBRslow.out.anelastic.eburgers_psp.V;
  fastV=VBRfast.out.anelastic.eburgers_psp.V;
  diff=abs((slowV-fastV)./slowV);
  if max(diff)>1e-5
    msg = ['FastBurger not matching PointWise calculation in eBurgers: ', num2str(max(diff))];
    disp(msg)
    TestResult.fail_message = msg;
    TestResult.passed = false;
  end
end
