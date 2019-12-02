function tau = Q_eBurgers_mxwll(VBR,Gu)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % tau = Q_eBurgers_mxwll(VBR,Gu)
  %
  % calculatues the maxwell time & limits for extended burgers model
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  % Gu     unrelaxed modulus [GPa]
  %
  % Output:
  % ------
  % tau.   structure of maxwell times including:
  %    .maxwell = steady state viscous maxwell time (i.e., eta / Gu)
  %    .L = lower limit of integration for high temp background
  %    .H = upper limit of integration for high temp background
  %    .P = center period of dissipation peak (if being used)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in parameters
  Burger_params=VBR.in.anelastic.eburgers_psp;
  bType=Burger_params.eBurgerFit;

  % state variables for either maxwell time or integration limits, peak loc:
  phi =  VBR.in.SV.phi ;
  T_K_mat = VBR.in.SV.T_K ; % temperature [K]
  P_Pa_mat = VBR.in.SV.P_GPa.*1e9 ; % convert pressure GPa to Pa = GPa*1e9
  d_mat = VBR.in.SV.dg_um ; % microns grain size

  % Scaling values from JF10
  TR = Burger_params.(bType).TR ;% Kelvins
  PR = Burger_params.(bType).PR *1e9; % convert pressure GPa to Pa = GPa*1e9
  dR = Burger_params.(bType).dR ; % microns grain size
  E = Burger_params.(bType).E ; % activation energy J/mol
  R = Burger_params.R ; % gas constant
  Vstar = Burger_params.(bType).Vstar ; % m^3/mol Activation Volume
  m_a = Burger_params.(bType).m_a ; % grain size exponent (anelastic)
  m_v = Burger_params.(bType).m_v ; % grain size exponent (viscous)

  % maxwell time calculation
  [visc_exists,missing]=checkStructForField(VBR,{'in','viscous','methods_list'},0);
  if Burger_params.useJF10visc || visc_exists==0
    % use JF10's exact relationship
    scale=((d_mat./dR).^m_v).*exp((E/R).*(1./T_K_mat-1/TR)).*exp((Vstar/R).*(P_Pa_mat./T_K_mat-PR/TR));
    scale=addMeltEffects(phi,scale,VBR.in.GlobalSettings,Burger_params);
    Tau_MR = Burger_params.(bType).Tau_MR ;
    tau.maxwell=Tau_MR .* scale ; % steady state viscous maxwell time
  else
    % use diffusion viscosity from VBR to get maxwell time
    visc_method=VBR.in.viscous.methods_list{1};
    eta_diff = VBR.out.viscous.(visc_method).diff.eta ; % viscosity for maxwell relaxation time
    tau.maxwell = eta_diff ./ Gu ; % maxwell relaxation time
  end

  % integration limits and peak location
  LHP=((d_mat./dR).^m_a).*exp((E/R).*(1./T_K_mat-1/TR)).*exp((Vstar/R).*(P_Pa_mat./T_K_mat-PR/TR));
  LHP=addMeltEffects(phi,LHP,VBR.in.GlobalSettings,Burger_params);
  tau.L = Burger_params.(bType).Tau_LR * LHP;
  tau.H = Burger_params.(bType).Tau_HR * LHP;
  tau.P = Burger_params.(bType).Tau_PR * LHP;
end

function scaleMat=addMeltEffects(phi,scaleMat,GlobalSettings,Burger_params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % scaleMat=addMeltEffects(phi,scaleMat,GlobalSettings,Burger_params)
  %
  % adds on Melt Effects
  %
  % Parameters:
  % ----------
  % phi              melt fraction
  % scaleMat         the initial maxwell time matrix
  % GlobalSettings   global settings structure with melt_enhancement flag
  % Burger_params    the parameter structure for burgers model
  %
  % Output:
  % ------
  % scaleMat        the maxwell time matrix, adjusted for small melt effect
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % sharper response than creep at phi_c, but less sensitive at higher phi (for HTB only)
  alpha = Burger_params.melt_alpha ; % post-critical melt fraction dependence
  phi_c = Burger_params.phi_c ; % critical melt fraction
  x_phi_c = Burger_params.x_phi_c ;% melt enhancement factor

  % x_phi_c adjustment ("nominally melt free" to truly melt free)
  if GlobalSettings.melt_enhancement==0
    x_phi_c=1;
  else
    scaleMat = scaleMat.* x_phi_c ;
  end

  % add melt effects
  [scale_mat_prime] = sr_melt_enhancement(phi,alpha,x_phi_c,phi_c) ;
  scaleMat = scaleMat ./ scale_mat_prime;
end
