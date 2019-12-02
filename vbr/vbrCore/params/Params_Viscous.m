function params = Params_Viscous(method)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = Params_Viscous(method)
  %
  % loads the parameters for a viscous method
  %
  % Parameters:
  % ----------
  % method    the method to load parameters for. If set to '', will return
  %           limited information
  %
  % Output:
  % ------
  % params    the parameter structure for the viscous method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  params.possible_methods={'HK2003','HZK2011','xfit_premelt'};

  % small-melt effect, Holtzman (these values get passed to the current paramter
  % structure for the current method)
  phi_c = [1e-5 1e-5 1e-5];
  x_phi_c = [5 1 5/2];

  if strcmp(method,'HK2003')
    % hirth and kohlstedt 2003
    params = load_HK03_flowlaw_constants(phi_c,x_phi_c); % load standard constants
    params.possible_mechs={'diff','disl','gbs'};
    params.func_name='sr_visc_calc_HK2003'; % the name of the matlab function
    params.citations={'Hirth and Kohlstedt, 2003, In Inside the Subduction Factory, J. Eiler (Ed.). https://doi.org/10.1029/138GM06 '};
    params.ch2o_o = 50; % reference water content [ppm] ("dry" below this value)
    params.P_dep_calc='yes'; % pressure-dependent calculation? 'yes' or 'no'.
  elseif strcmp(method,'HZK2011')
    % hansen et al., 2011
    params = load_HZK2011_flowlaw_constants(phi_c,x_phi_c); %  load standard constants
    params.possible_mechs={'diff','disl','gbs'};
    params.citations={'Hansen, Zimmerman and Kohlstedt, 2011, J. Geophys. Res., https://doi.org/10.1029/2011JB008220'};
    params.func_name='sr_visc_calc_HZK2011'; % the name of the matlab function
    params.P_dep_calc='yes'; % pressure-dependent calculation? 'yes' or 'no'.
  elseif strcmp(method,'xfit_premelt')
    % YT2016 solidus (diffusion creep only)
    params.func_name='visc_calc_xfit_premelt'; % the name of the matlab function
    params.citations={'Yamauchi and Takei, 2016, J. Geophys. Res. Solid Earth, https://doi.org/10.1002/2016JB013316'};
    % near-solidus and melt effects
    params.alpha=25; % taken from diff. creep value of HZK2011. YT2016 call this lambda.
    params.T_eta=0.94;
    params.gamma=5;

    % method to use for dry (melt-free) diff. creep viscosity
    params.eta_dry_method='xfit_premelt';

    % flow law constants for YT2016
    params.Tr_K=1200+273; % p7817 of YT2016, second paragraph
    params.Pr_Pa=1.5*1e9; % p7817 of YT2016, second paragraph
    params.eta_r=6.22*1e21; % figure 20 of reference paper
    params.H=462.5*1e3; % activation energy [J/mol], figure 20 of YT2016
    params.V=7.913*1e-6; % activation vol [m3/mol], figure 20 of YT2016
    params.R=8.314; % gas constant [J/mol/K]
    params.m=3; % grain size exponent
    params.dg_um_r=.004*1e6; % reference grain size [um]
    % note that in YT2016 (section 4.4), YT2016 fit for H, V following
    % Priestly & McKenzie EPSL 2013 and dg_um = dg_um_r. This assumes that
    % the grain size is at the mean grain size of the upper mantle, which
    % Priestly & McKenzie calculate as 4 mm.
  end


end

function params = load_HK03_flowlaw_constants(phi_c,x_phi_c)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = load_HK03_flowlaw_constants(phi_c,x_phi_c)
  %
  % loads the flow law parameters for HK2003
  %
  % Parameters:
  % ----------
  % phi_c    critical melt fraction for each mechanism
  % x_phi_c  small-melt factor for each mechanism
  %
  % Output:
  % ------
  % params    the parameter structure with flow law constants
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Coble Diffusion creep (GB)
  % dry
  params.diff.A = 1.5e9 ; % preexponential for coble diffusion creep
  params.diff.Q = 375e3 ;% activation energy for coble diffusion creep
  params.diff.V = 10e-6 ; % activation volume for coble diff creep
  params.diff.p = 3 ; % grain size exponent
  params.diff.n = 1 ; % stress exponent
  params.diff.r = 0 ; % water fugacity exponent
  params.diff.alf = 25 ; % melt factor
  params.diff.phi_c=phi_c(1);
  params.diff.x_phi_c=x_phi_c(1);

  % wet
  params.diff.A_wet = 2.5e7 ; % preexponential for coble diffusion creep
  params.diff.Q_wet = 375e3 ;% activation energy for coble diffusion creep
  params.diff.V_wet = 10e-6 ; % activation volume for coble diff creep
  params.diff.p_wet = 3 ; % grain size exponent
  params.diff.n_wet = 1 ; % stress exponent
  params.diff.r_wet = 0.7 ; % water fugacity exponent
  params.diff.alf_wet = 25 ; % melt factor
  params.diff.phi_c_wet=phi_c(1);
  params.diff.x_phi_c_wet=x_phi_c(1);

  %% Dislocation creep
  % dry
  params.disl.A = 1.1e5 ; % preexponential
  params.disl.Q = 530e3 ;% activation energy
  params.disl.V = 15e-6 ; % activation volume (HK03 doesn't report, using value from LH12 here)
  params.disl.n = 3.5 ; % stress exponent
  params.disl.p = 0; % grain size exponent
  params.disl.alf = 30 ; % melt factor
  params.disl.r = 0 ; % water fugacity exponent
  params.disl.phi_c=phi_c(2);
  params.disl.x_phi_c=x_phi_c(2);
  % wet
  params.disl.A_wet = 1600.0 ; % preexponential
  params.disl.Q_wet = 520e3 ;% activation energy
  params.disl.V_wet = 22e-6 ; % activation volume
  params.disl.n_wet = 3.5 ; % stress exponent
  params.disl.p_wet = 0; % grain size exponent
  params.disl.alf_wet = 30 ; % melt factor
  params.disl.r_wet = 1.2 ; % water fugacity exponent
  params.disl.phi_c_wet=phi_c(2);
  params.disl.x_phi_c_wet=x_phi_c(2);

  % GBS disl accomodated (dry only)
  params.gbs.A_lt1250 = 6500  ; % preexponential for GBS-disl creep
  params.gbs.Q_lt1250 = 400e3  ; % activation energy for GBS-disl creep
  params.gbs.V_lt1250 = 15e-6  ; % activation volume
  params.gbs.p_lt1250 = 2 ; % grain size exponent
  params.gbs.n_lt1250 = 3.5 ; % stress exponent
  params.gbs.r_lt1250 = 0 ; % water fugacity exponent
  params.gbs.alf_lt1250 = 35 ; % melt factor
  params.gbs.phi_c_lt1250 = phi_c(3);
  params.gbs.x_phi_c_lt1250 = x_phi_c(3);

  params.gbs.A_gt1250 = 4.7e10  ; % preexponential for GBS-disl creep
  params.gbs.Q_gt1250 = 600e3  ; % activation energy for GBS-disl creep
  params.gbs.V_gt1250 = 15e-6  ; % activation volume
  params.gbs.p_gt1250 = 2 ; % grain size exponent
  params.gbs.n_gt1250 = 3.5 ; % stress exponent
  params.gbs.r_gt1250 = 0 ; % water fugacity exponent
  params.gbs.alf_gt1250 = 35 ; % melt factor
  params.gbs.phi_c_gt1250=phi_c(3);
  params.gbs.x_phi_c_gt1250=x_phi_c(3);

end

function params = load_HZK2011_flowlaw_constants(phi_c,x_phi_c)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = load_LH12_flowlaw_constants(phi_c,x_phi_c)
  %
  % loads the flow law parameters for HZK2011
  %
  % Parameters:
  % ----------
  % phi_c    critical melt fraction for each mechanism
  % x_phi_c  small-melt factor for each mechanism
  %
  % Output:
  % ------
  % params    the parameter structure with flow law constants
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Coble Diffusion creep (GB)
  params.diff.A = 10^7.6 ; % preexponential for coble diffusion creep
  params.diff.Q = 375e3 ;% activation energy for coble diffusion creep
  params.diff.V = 10e-6 ; % activation volume for coble diff creep
  params.diff.p = 3 ; % grain size exponent
  params.diff.alf = 25 ; % melt factor
  params.diff.r = 0 ; % water fugacity exponent
  params.diff.n = 1 ; % stress exponent
  params.diff.phi_c=phi_c(1);
  params.diff.x_phi_c=x_phi_c(1);

  % Dislocation creep
  params.disl.A = 1.1e5 ; % preexponential
  params.disl.Q = 530e3 ;% activation energy
  params.disl.V = 15e-6 ; % activation volume
  params.disl.n = 3.5 ; % stress exponent
  params.disl.p = 0 ; % grain size exponent
  params.disl.alf = 30 ; % melt factor
  params.disl.r = 0 ; % water fugacity exponent
  params.disl.phi_c=phi_c(2);
  params.disl.x_phi_c=x_phi_c(2);

  % GBS disl accomodated
  params.gbs.A = 10^4.8  ; % preexponential for GBS-disl creep
  params.gbs.Q = 445e3  ; % activation energy for GBS-disl creep
  params.gbs.V = 15e-6  ; % activation volume
  params.gbs.p = 0.73 ; % grain size exponent
  params.gbs.n = 2.9 ; % stress exponent
  params.gbs.alf = 35 ; % melt factor
  params.gbs.r = 0 ; % water fugacity exponent
  params.gbs.phi_c=phi_c(3);
  params.gbs.x_phi_c=x_phi_c(3);
end
