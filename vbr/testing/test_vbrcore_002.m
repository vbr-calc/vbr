function TestResult = test_vbrcore_002()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_002()
%
% test of pre-melting viscosity flags
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
  disp('    **** Running test_vbrcore_002 ****')

  VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
  VBR.in.anelastic.methods_list={'xfit_premelt'};

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

  % call VBR with different dry viscosity methods for xfit_premelt
  visc_meths_to_use={'xfit_premelt';'HK2003';'HZK2011'};
  for ivisc=1:numel(visc_meths_to_use)
    VBR.in.viscous.xfit_premelt.eta_dry_method=visc_meths_to_use{ivisc};
    VBRout(ivisc).VBR=VBR_spine(VBR);
  end

  % check if they're different
  for ivisc=2:numel(visc_meths_to_use)
    vmeth=visc_meths_to_use{ivisc};
    this_eta=VBRout(ivisc).VBR.out.viscous.xfit_premelt.diff.eta;
    ref_eta=VBRout(1).VBR.out.viscous.xfit_premelt.diff.eta;
    deta=abs(this_eta-ref_eta);
    if sum(deta)==0
      disp('Diffusion creep viscosities are identical')
      TestResult=false;
    end
  end

  % check if they match the dry phi
  VBR.in.SV.phi(:)=0;
  visc_meths_to_use={'HK2003';'HZK2011'};
  for ivisc=1:numel(visc_meths_to_use)
    vmeth=visc_meths_to_use{ivisc};
    VBR.in.viscous.methods_list={'xfit_premelt';vmeth};
    VBR.in.viscous.xfit_premelt.eta_dry_method=visc_meths_to_use{ivisc};
    VBR=VBR_spine(VBR);

    % melt free calculated by xfit_premelt
    this_eta=VBR.out.viscous.xfit_premelt.diff.eta_meltfree;

    % the diffusion creep visc calculated with phi=0 directly
    ref_eta=VBR.out.viscous.(vmeth).diff.eta;

    % the two should be identical
    deta=abs(this_eta-ref_eta);
    if sum(deta)>0
      disp('Melt-free diffusion creep viscosities not matching')
      TestResult=false;
    end
  end

end
