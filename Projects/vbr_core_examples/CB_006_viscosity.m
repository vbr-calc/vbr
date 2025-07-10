function VBR = CB_006_viscosity()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_006_viscosity.m
%
%   Calculates viscosity using different flow laws, plots log-log plots of
%   composite strain rate, effective viscosity vs stress, grain size for
%   all full flow-law viscous methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%write method list  %%
  VBR.in.viscous.methods_list={'HK2003';'HZK2011'};

%% Define the Thermodynamic State %%
  VBR.in.SV.dg_um=logspace(-6,-1,80)*1e6;
  sz=size(VBR.in.SV.dg_um);
  VBR.in.SV.phi = zeros(sz); % melt raction
  VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
  VBR.in.SV.T_K = 1473 * ones(sz); % temperature [K]
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]

%% CALL THE VBR CALCULATOR %%
  [VBR_vs_dg] = VBR_spine(VBR) ;

%% adjust input, call again
  VBR.in.SV=struct(); % clear out SV struct to clear default fields
  VBR.in.SV.sig_MPa=logspace(-1,2,50);
  sz=size(VBR.in.SV.sig_MPa);
  VBR.in.SV.dg_um=1000 * ones(sz);
  VBR.in.SV.phi = zeros(sz); % melt raction
  VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
  VBR.in.SV.T_K = 1473 * ones(sz); % temperature [K]
  [VBR_vs_sig] = VBR_spine(VBR) ;

%% Plot strain rates, viscosity %%
  figure()
  for imeth=1:numel(VBR_vs_dg.in.viscous.methods_list)
    vmeth=VBR_vs_dg.in.viscous.methods_list{imeth};
    subplot(2,2,1)
    hold all
    plot(log10(VBR_vs_dg.in.SV.dg_um),log10(VBR_vs_dg.out.viscous.(vmeth).sr_tot))

    subplot(2,2,2)
    hold all
    plot(log10(VBR_vs_dg.in.SV.dg_um),log10(VBR_vs_dg.out.viscous.(vmeth).eta_total))

    subplot(2,2,3)
    hold all
    plot(log10(VBR_vs_sig.in.SV.sig_MPa),log10(VBR_vs_sig.out.viscous.(vmeth).sr_tot))

    subplot(2,2,4)
    hold all
    plot(log10(VBR_vs_sig.in.SV.sig_MPa),log10(VBR_vs_sig.out.viscous.(vmeth).eta_total))
  end

  subplot(2,2,1)
  box on; xlabel('log10 d [um]'); ylabel('log10 total strain rate [s]')

  subplot(2,2,2)
  box on; xlabel('log10 d [um]'); ylabel('log10 effective viscosity [Pa s]')

  subplot(2,2,3)
  box on; xlabel('log10 \sigma [MPa]'); ylabel('log10 total strain rate [s]')

  subplot(2,2,4)
  box on; xlabel('log10 \sigma [MPa]'); ylabel('log10 effective viscosity [Pa s]')
saveas(gcf,'./figures/CB_006_viscosity.png')
end