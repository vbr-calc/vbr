function TestResult = test_vbrcore_004()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_004()
%
% tests the VBR.in.GlobalSettings structure, particularly small-melt settings
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
  disp('    **** Running test_vbrcore_004 ****')

  % melt enhacement = 0 (default)
  VBR = initVBR();
  VBR_1=VBR_spine(VBR);
  if VBR_1.in.GlobalSettings.melt_enhancement ~=0
    TestResult=false;
    disp('      WARNING: melt_enhancement not properly set!!! Should be 0.')
  end

  % modify the melt_enhancement flag
  VBR = initVBR();
  VBR.in.GlobalSettings.melt_enhancement=1;
  VBR_2=VBR_spine(VBR);
  if VBR_2.in.GlobalSettings.melt_enhancement ~=1
    TestResult=false;
    disp('      WARNING: melt_enhancement not properly set!!! Should be 1.')
  end

  % change phi_c, make sure it propagates where it should:
  % (1) anelastic method has the correct phi_c
  % (2) viscous methods have correct phi_c
  % (3) viscous and anelastic match
  VBR = initVBR();
  VBR.in.GlobalSettings.phi_c=[0.01 0.001 0.0001];
  VBR_3=VBR_spine(VBR);
  for imeth =1:numel(VBR_3.in.anelastic.methods_list)
    meth=VBR_3.in.anelastic.methods_list{imeth};
    phi_c=VBR_3.in.anelastic.(meth).phi_c;
    if phi_c ~= VBR.in.GlobalSettings.phi_c(1)
      TestResult=false;
      disp(['      WARNING: phi_c not properly set for ',meth])
    end

    for vmethi =1:numel(VBR_3.in.viscous.methods_list)
      vmeth=VBR_3.in.viscous.methods_list{vmethi};
      vphic=VBR_3.in.viscous.(vmeth).diff.phi_c;
      if vphic ~= VBR.in.GlobalSettings.phi_c(1)
        TestResult=false;
        disp(['      WARNING: diff phi_c not properly set for ',vmeth])
      elseif vphic~=phi_c
        TestResult=false;
        disp(['      WARNING: diff phi_c not matching for ',vmeth,' and ',meth])
      end
    end
  end
end

function VBR = initVBR();
  % loads the initial VBR structure
  VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
  VBR.in.viscous.methods_list={'HK2003';'HZK2011'};
  VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};

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
  VBR.in.SV.phi(VBR.in.SV.T_K>=VBR.in.SV.Tsolidus_K)=0.01;
end
