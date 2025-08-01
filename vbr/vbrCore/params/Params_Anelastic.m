function params = Params_Anelastic(method,GlobalParams)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = Params_Anelastic(method)
  %
  % loads the parameters for an anelastic method.
  %
  % Parameters:
  % ----------
  % method    the method to load parameters for. If set to '', will return
  %           limited information
  % GlobalParams   the Global Parameters structure, not required. Only used to
  %                set the small-melt fraction effect.
  %
  % Output:
  % ------
  % params    the parameter structure for the anelastic method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % available anelastic methods
  params.possible_methods={'eburgers_psp'; 'andrade_psp'; 'xfit_mxw'; 'xfit_premelt'; ...
                           'andrade_analytical'; 'backstress_linear';};

  if strcmp(method,'eburgers_psp')
    % extended burgers parameters
    params.func_name='Q_eBurgers_decider'; % the name of the matlab function
    params.citations={'Faul and Jackson, 2015, Ann. Rev. of Earth and Planetary Sci., https://doi.org/10.1146/annurev-earth-060313-054732',...
                      'Jackson and Faul, 2010, Phys. Earth Planet. Inter., https://doi.org/10.1016/j.pepi.2010.09.005'};
    params.method='PointWise'; % 'FastBurger' uses look-up table for integration, only works for high temp background
                               % 'PointWise' integrates every frequency and state variable condition
    params.nTauGlob=3000; % points for global Tau discretization ('FastBurger' ONLY)
    params.R = 8.314 ; % gas constant
    params.eBurgerFit='bg_only'; % 'bg_only' or 'bg_peak' or 's6585_bg_only'
    params.useJF10visc=1; % if 1, will use the scaling from JF10 for maxwell time. If 0, will calculate
    params.integration_method=0; % 0 for trapezoidal, 1 for quadrature.
    params.tau_integration_points = 500 ; % number of points for integration of high-T background if trapezoidal
    params=load_JF10_eBurger_params(params);
  end

  if strcmp(method,'andrade_psp')
    % ANDRADE (pseudoperiod scaling) parameters
    params.func_name='Q_Andrade_PseudoP_f'; % the name of the matlab function
    params.citations={'Jackson and Faul, 2010, Phys. Earth Planet. Inter., https://doi.org/10.1016/j.pepi.2010.09.005'};
    params.n = 0.33 ; % 1/3 ;
    params.Beta = 0.020;
    params.Tau_MR = 10^5.3 ;
    params.E = 303e3 ; %J/mol
    params.G_UR = 62.2; % GPa, for reference only.

    % reference values (uses eBurgers values from above)
    params.TR = 900+273;% Kelvins
    params.PR = 0.2; % confining pressure of experiments, GPa
    params.dR = 3.1 ; % 3.1 microns grain size
    params.R = 8.314 ; % gas constant
    params.Vstar = 10e-6 ; % m^3/mol (Activation Volume? or molar volume?)
    params.m = 1 ;

    % the GBS relaxation peak (experimental... leave commented until further notice)
    % params.Te = 0.1 ;
    % params.Tgbs = 0.0833 ;% sec
    % params.Delta = 0.3 ; % Relaxation strength
  end

  if strcmp(method,'andrade_mxw')
    % ANDRADE parameters (from Sundberg+Cooper). Experimental, do not use.
    params.func_name='Q_Andrade_Mxw_f'; % the name of the matlab function
    params.alf = 1/2 ; % 1/3 ;
    % scaling option:
    %   1= Bunton's thesis- Andrade transient Beta only a function of G, eta_diff_ss
    %   2= Mixture of 1 and SundbergCooper2010-- add a bump.
    params.scaling_opt=1 ;
    % Bump on (1) or off (0) --
    params.bump = 0 ;
    % for using Bunton's flow law in thesis for expt fitting:
    params.eta0_local = 1e7 ; % no idea !

  end

  if strcmp(method,'xfit_mxw')
    % xfit_mxw parameters
    params.citations={'McCarthy, Takei, Hiraga, 2011 JGR http://dx.doi.org/10.1029/2011JB008384'};
    params.func_name='Q_xfit_mxw'; % the name of the matlab function
    params.fit='fit1'; % the mantle scaling fit

    % high temp background at tau_normalized < 1e-11, X = beta2 * tau_n ^ alpha2

    params.beta2 = 1853.0 ;
    params.beta2_fit2=8.476;
    params.alpha2 = 0.5 ;

    % parameters for dissipation spectrum at tau_normalized > 1e-11
    % Alpha = params.Alpha_a - params.Alpha_b./(1+params.Alpha_c*(tau_norm_vec.^params.Alpha_taun));
    % X = beta1 * tau_n ^ Alpha
    params.tau_cutoff=1e-11; % the transition tau from HTB to peak (for fit 1)
    params.tau_cutoff_fit2=5e-6; % the value for fit 2 (fit 1 used by default)
    params.beta1 = 0.32 ;
    params.Alpha_a=0.39 ;
    params.Alpha_b=0.28;
    params.Alpha_c=2.6;
    params.Alpha_taun=0.1;
    params.description='master curve maxwell scaling';
  end

  if strcmp(method,'xfit_premelt')
    % xfit_premelt parameters
    params.citations={'Yamauchi and Takei, 2016, J. Geophys. Res. Solid Earth, https://doi.org/10.1002/2016JB013316';
                      'Yamauchi and Takei, 2024, J. Geophys. Res. Solid Earth, https://doi.org/10.1029/2023JB027738'};
    params.func_name='Q_xfit_premelt'; % the name of the matlab function

    % high temp background spectrum
    params.alpha_B=0.38; % high temp background exponent
    params.A_B=0.664; % high temp background dissipation strength

    % pre-melting dissipation peak settings:
    params.tau_pp=6*1e-5; % peak center, table 4 of YT16, paragraph before eq 10
    params.Ap_fac_1=0.01;
    params.Ap_fac_2=0.4;
    params.Ap_fac_3=0.03;
    params.sig_p_fac_1=4;
    params.sig_p_fac_2=37.5;
    params.sig_p_fac_3=7;
    params.Ap_Tn_pts=[0.91,0.96,1]; % Tn cuttoff points
    params.sig_p_Tn_pts=[0.92,1]; % Tn cuttoff points

    % note: sig_p_fac2 and Ap_fac_2 above are combinations of the other constants
    % and appear in the original papers as:
    % sig_p_fac2 = (sig_p_fac_3-sig_p_fac_1) / (sig_p_Tn_pts(2) - sig_p_Tn_pts(1))
    % Ap_fac_2 = (Ap_fac_3-Ap_fac_1) / (Ap_Tn_pts(3) - Ap_Tn_pts(1))

    % melt effects. The following beta values are set to 0.0 within Q_xfit_premelt
    % if include_direct_melt_effect = 0, corresponding to YT2016. If set to 1,
    % the scaling will follow YT2024. Additionally, include_direct_melt_effect=1
    % will trigger different poro-elastic behavior.
    params.include_direct_melt_effect = 0; % set to 1 to include YT2024 melt effect
    params.Beta=1.38; % this is determined in YT2024, named Beta_P in YT2024 eq 5
    params.Beta_B=6.94; % YT2024 only
    params.poro_Lambda = 4.0; % Table 6 YT2024,
    params.description='pre-melting scaling';
  end

  if strcmp(method, 'andrade_analytical')
      params.description='analytical Andrade model';
      params.citations = {...
           'Andrade, 1910, Proceedings of the Royal Society of London, https://doi.org/10.1098/rspa.1910.0050'; ...
           'Cooper, 2002, Reviews in mineralogy and geochemistry, https://doi.org/10.2138/gsrmg.51.1.253'; ...
           'Lau and Holtzman, 2019, GRL. https://doi.org/10.1029/2019GL083529';};
      params.func_name='Q_andrade_analytical';
      params.alpha = 1/3; % the andrade exponent
      params.Beta = 1e-4; % andrade pre-factor
      params.viscosity_method = 'calculated'; % one of 'calculated' or 'fixed'
      params.viscosity_method_mechanism = 'diff'; % one of the viscous deformation mechanism structure fields
      params.eta_ss = 1e23; % only used if params.viscosity_method == 'fixed'
  end


  if strcmp(method, 'backstress_linear')
    params.func_name='Q_backstress_linear'; % the name of the matlab function
    params.citations={'Hein et al., 2025, ESS Open Archive (Submitted to JGR Solid Earth ), https://doi.org/10.22541/essoar.174326672.28941810/v1'};
    params.description='Linearized backstress model.';
    
    params.sig_p_sig_dc_factor = 0.8; % see supplement figure S12    
    params.burgers_vector_nm = .5; % burgers vector in micrometers
    params.Beta = 2; % geometric constant

    params.Q_J_per_mol = 450 *1e3; % activation energy J/mol, DeltaF in text    
    params.A = 10^6.94; % Pre-exponent low-temperature plasticity, units are MPa−2 s−1
    params.pierls_barrier_GPa = 3.1; % symbol in text is capital Sigma
    params.sig_p_sig_dc_factor = 0.8; % see supplement figure S12
    
    params.G_UR = 65; % GPa    
    params.M_GPa = 135; % hardening modulus GPa    
    params.SV_required = {'T_K'; 'sig_MPa' ; 'dg_um'};
    params.print_experimental_message = 1;
    params.experimental_message = "Note: the linearized backstress model is currently under development. While it nominally works, we are still working to verify correctness.";

  end 

  % set steady-state melt dependence for diff. creep (i.e., exp(-alpha * phi))
  HK2003 = Params_Viscous('HK2003'); % viscous parameters
  params.melt_alpha = HK2003.diff.alf ;

  % pull in the small melt effect parameter values -- use diffusion creep value
  if ~exist('GlobalParams')
    GlobalParams = Params_Global();
  end
  [phi_c,x_phi_c]=setGlobalMeltEffects(GlobalParams);
  params.phi_c=phi_c(1);
  params.x_phi_c=x_phi_c(1);
end


function params=load_JF10_eBurger_params(params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads fitting parameters
  %
  % reminder: reference unrelaxed modulus (G_UR) is not used by elastic methods
  % and is included here for reference only. To use it, set
  %
  %    VBR.in.elastic.anharmonic.Gu_0_ol=params.bg_only.G_UR
  %
  % after loading the param file. Note that JF10 define their references at
  % 900C,0.2GPa so you have to also ajust the anharmonic reference temperature
  % and pressure or project params.bg_only.G_UR to STP.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % multiple sample best high-temp background only fit:
  params.bg_only.dR = 13.4; % ref grain size in microns
  params.bg_only.G_UR = 62.5 ; % GPa, unrel. G, reference val.
  params.bg_only.E = 303000 ; % J/mol
  params.bg_only.m_a = 1.19 ; % grain size exponent for tau_i, i in (L,H,P)
  params.bg_only.alf = 0.257 ; % high temp background tau exponent
  params.bg_only.DeltaB = 1.13 ;% relaxation strength..
  params.bg_only.Tau_LR = 1e-3 ; % Relaxation time lower limit reference
  params.bg_only.Tau_HR = 1e7 ; % Relaxation time higher limit reference
  params.bg_only.Tau_MR = 10^6.95 ; % Reference Maxwell relaxation time
  params.bg_only.DeltaP=0; % no peak, set to 0
  params.bg_only.sig=0;% no peak, set to 0
  params.bg_only.Tau_PR=0;% no peak, set to 0

  % multiple sample best high-temp background + peak fit:
  params.bg_peak.DeltaP=0.057; % relaxation strength of peak
  params.bg_peak.sig=4; % sigma, peak breadth
  params.bg_peak.Tau_PR=10^-3.4; % center maxwell time
  params.bg_peak.dR = 13.4; % ref grain size in microns
  params.bg_peak.G_UR = 66.5 ; % GPa, unrel. G, reference val.
  params.bg_peak.E = 360000 ; % J/mol
  params.bg_peak.m_a = 1.31 ; % grain size exponent for tau_i, i in (L,H,P)
  params.bg_peak.alf = 0.274 ; % high temp background tau exponent
  params.bg_peak.DeltaB = 1.13 ;% relaxation strength of background.
  params.bg_peak.Tau_LR = 1e-3 ; % Relaxation time lower limit reference
  params.bg_peak.Tau_HR = 1e7 ; % Relaxation time higher limit reference
  params.bg_peak.Tau_MR = 10^7.48 ; % Reference Maxwell relaxation time

  % single sample 6585 fit, HTB only
  params.s6585_bg_only.dR = 3.1; % ref grain size in microns
  params.s6585_bg_only.G_UR = 62.0 ; % GPa, unrel. G, reference val.
  params.s6585_bg_only.E = 303000 ; % J/mol
  params.s6585_bg_only.m_a = 1.19 ; % grain size exponent for tau_i, i in (L,H,P)
  params.s6585_bg_only.alf = 0.33 ; % high temp background tau exponent
  params.s6585_bg_only.DeltaB = 1.4 ;% relaxation strength.
  params.s6585_bg_only.Tau_LR = 1e-2 ; % Relaxation time lower limit reference
  params.s6585_bg_only.Tau_HR = 1e6 ; % Relaxation time higher limit reference
  params.s6585_bg_only.Tau_MR = 10^5.2 ; % Reference Maxwell relaxation time
  params.s6585_bg_only.DeltaP=0; % no peak, set to 0
  params.s6585_bg_only.sig=0;% no peak, set to 0
  params.s6585_bg_only.Tau_PR=0;% no peak, set to 0

  % single sample 6585 fit, HTB + dissipation peak
  params.s6585_bg_peak.DeltaP=0.07; % relaxation strength of peak
  params.s6585_bg_peak.sig=4; % sigma, peak breadth
  params.s6585_bg_peak.Tau_PR=10^-2.9; % center maxwell time
  params.s6585_bg_peak.dR = 3.1; % ref grain size in microns
  params.s6585_bg_peak.G_UR = 66.5 ; % GPa, unrel. G, reference val.
  params.s6585_bg_peak.E = 327000 ; % J/mol
  params.s6585_bg_peak.m_a = 1.19 ; % grain size exponent for tau_i, i in (L,H,P)
  params.s6585_bg_peak.alf = 0.33 ; % high temp background tau exponent
  params.s6585_bg_peak.DeltaB = 1.4 ;% relaxation strength..
  params.s6585_bg_peak.Tau_LR = 1e-2 ; % Relaxation time lower limit reference
  params.s6585_bg_peak.Tau_HR = 1e6 ; % Relaxation time higher limit reference
  params.s6585_bg_peak.Tau_MR = 10^5.4 ; % Reference Maxwell relaxation time

  % parameters commmon to all the above
  meths={'s6585_bg_peak';'s6585_bg_only';'bg_peak';'bg_only'};
  for imeth=1:numel(meths)
    meth=meths{imeth};
    params.(meth).TR=1173; % ref temp [K]
    params.(meth).PR = 0.2; % ref confining pressure of experiments, GPa
    params.(meth).Vstar = 10e-6 ; % m^3/mol (Activation Volume? or molar volume?)
    params.(meth).m_v = 3 ; % viscous grain size exponent for maxwell time
  end

end
