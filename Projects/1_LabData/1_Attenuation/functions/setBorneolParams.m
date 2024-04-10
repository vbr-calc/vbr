function params = setBorneolParams()
  % set the general viscous parameters for borneol.
  % near-solidus and melt effects
  params.alpha=25;
  params.T_eta=0.94; % eqn 17,18- T at which homologous T for premelting.
  params.gamma=5;
  % flow law constants for YT2016
  params.Tr_K=23+273; % reference temp [K]
  params.Pr_Pa=0; % reference pressure [Pa]
  params.eta_r=7e13;% reference eta (eta at Tr_K, Pr_Pa)
  params.H=147*1e3; % activation energy [J/mol]
  params.V=0; % activation vol [m3/mol]
  params.R=8.314; % gas constant [J/mol/K]
  params.m=2.56; % grain size exponent
  params.dg_um_r=34.2 ; % eference grain size [um]
end