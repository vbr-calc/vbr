function VBR = visc_calc_xfit_premelt(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % VBR = visc_calc_xfit_premelt(VBR)
  %
  % calculates the viscosity from Yamauchi and Takei, JGR 2016,
  % https://doi.org/10.1002/2016JB013316
  %
  % Parameters:
  % -----------
  % VBR   the VBR structure
  %
  %       required fields are the state variables in VBR.in.SV.* including a
  %       solidus, Tsolidus_K.
  %
  %       if the eta_dry_method parameter for this method is set to
  %       'xfit_premelt', will use the exact viscosity from Yamauchi and
  %       Takei for the melt-free viscosity, otherwise eta_dry_method can be
  %       set to any VBR viscous method, see vbrListMethods()
  %
  % Output:
  % -------
  % VBR   the VBR structure with new field VBR.out.viscous.YT2016_solidus.diff
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % parameter checks
  if ~isfield(VBR.in,'viscous')
    VBR.in.viscous=struct();
  end
  if isfield(VBR.in.viscous,'xfit_premelt')==0
    params=Params_Viscous('xfit_premelt');
  else
    params=VBR.in.viscous.xfit_premelt;
  end

  % calculate solidus-depdendent activation energy factor & melt effects
  Tprime=VBR.in.SV.T_K./VBR.in.SV.Tsolidus_K;
  A_n=calcA_n(Tprime,VBR.in.SV.phi,params);

  % calculate melt-free viscosity
  visc_method=params.eta_dry_method;
  if strcmp(visc_method,'xfit_premelt')
    % use exactly what is in YT2016
    eta_dry=YT2016_dryViscosity(VBR,params);
  else
    % use a general olivine flow law to get melt-free diffusion-creep visc
    % need to re-run with phi=0 without losing other state variables
    VBRtemp=VBR;
    VBRtemp.in.viscous.methods_list={visc_method}; % only use one method
    VBRtemp.in.SV.phi=0; % need melt-free viscosity
    VBRtemp=spineGeneralized(VBRtemp,'viscous');
    eta_dry = VBRtemp.out.viscous.(visc_method).diff.eta ;
  end

  % calculate full viscosity
  VBR.out.viscous.xfit_premelt.diff.eta=A_n .* eta_dry;
  VBR.out.viscous.xfit_premelt.diff.eta_meltfree=eta_dry;
end

function eta = YT2016_dryViscosity(VBR,params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % eta = YT2016_dryViscosity(VBR,params)
  %
  % exact viscosity function for melt-free diffusion creep viscosity from
  % Yamauchi and Takei, JGR 2016
  %
  % Parameters:
  % -----------
  % VBR    the VBR struct with state variable fields in VBR.in.SV
  % params the YT2016 parameter structure
  %
  % Output:
  % -------
  % eta    melt-free diffusion creep viscosity
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % reference values
    Tr=params.Tr_K; % ref. temp [K]
    Pr=params.Pr_Pa; % ref. pressure [Pa]
    eta_r=params.eta_r; % viscosity at (Tr,Pr,dr) [Pa s]
    dr=params.dg_um_r; % ref. grain size [um]

  % constants
    H=params.H; % activation energy [J/mol], figure 20 of reference paper
    Vol=params.V; % activation vol [m3/mol], figure 20 of reference paper
    R=params.R; % gas constant [J/mol/K]
    m=params.m; % grain size exponent -- but this does not matter since dr = d.

  % calculate the viscoscity
    P=VBR.in.SV.P_GPa*1e9;
    eta=eta_r.*(VBR.in.SV.dg_um./dr).^m  .* ...
          exp(Vol/R.*(P./VBR.in.SV.T_K-Pr./Tr)) .* ...
          exp(H/R.*(1./VBR.in.SV.T_K-1./Tr));

end

function A_n = calcA_n(Tn,phi,params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % A_n = calcA_n(Tn,phi,params)
  %
  % calculates near-solidus and melt effects from Yamauchi and Takei, JGR 2016
  %
  % Parameters:
  % -----------
  % Tn    solidus in Kelvin
  % phi   melt fraction, 0<=phi<=1
  % params the YT2016 parameter structure
  %
  % Output:
  % -------
  % A_n    modified pre-exponential constant. effective viscosity eta is
  %            eta = A_n * eta_dry
  %        where eta_dry is the melt-free diffusion creep viscosity.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  T_eta=params.T_eta;
  gamma=params.gamma;
  lambda=params.alpha; % rename to be consistent with YT2016 nomenclature

  A_n=zeros(size(Tn));

  A_n(Tn<T_eta)=1;

  msk=(Tn >= T_eta) & (Tn < 1);
  A_n(msk)=exp(-(Tn(msk)-T_eta)./(Tn(msk)-Tn(msk)*T_eta)*log(gamma));

  msk=(Tn > 1);
  A_n(msk)=exp(-lambda*phi(msk))/gamma;
end
