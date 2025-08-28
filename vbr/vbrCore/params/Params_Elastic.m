function [params] = Params_Elastic(method,GlobalParams)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = Params_Elastic(method)
  %
  % loads the parameters for an elastic method
  %
  % Parameters:
  % ----------
  % method    the method to load parameters for. If set to '', will return
  %           limited information
  % GlobalParams   option GlobalParams flag, not required and not currently used
  %
  % Output:
  % ------
  % params    the parameter structure for the elastic method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  params.possible_methods={'anharmonic'; 'anh_poro'; 'SLB2005'};

  if ~exist('GlobalParams')
    GlobalParams = Params_Global();
  end

  if strcmp(method,'anharmonic')
    params.func_name='el_anharmonic'; % the name of the matlab function

    params.T_K_ref = 300 ;% room temp [K]
    params.P_Pa_ref = 1e5;% 1 atm [Pa]
    params.Gu_0_ol = 81; % olivine reference shear modulus [GPa]
    params.Ku_0_ol = 129; % olivine reference bulk modulus [GPa]

    params.reference_scaling = 'default';
    params.available_reference_scaling = {'default'; 'upper_mantle'};

    params.temperature_scaling = 'isaak';
    params.available_temperature_scaling = {'isaak'; 'cammarano'; 'upper_mantle';};

    params.pressure_scaling = 'cammarano';
    params.available_pressure_scaling = {'cammarano'; 'abramson'; 'upper_mantle';};

    params.isaak.citations = {'Isaak, D. G. (1992), "High‐temperature elasticity of iron‐bearing olivines", J. Geophys. Res., 97( B2), 1871– 1885, https://doi.org/10.1029/91JB02675';};
    params.isaak.dG_dT = -1.36 * 1e7 ; % Pa/K (so 13.6 in MPa/K)
    params.isaak.dK_dT = -1.8 * 1e7; % Pa/K

    params.cammarano.citations = {'Cammarano et al. (2003), "Inferring upper-mantle temperatures from seismic velocities", Physics of the Earth and Planetary Interiors, Volume 138, Issues 3–4, https://doi.org/10.1016/S0031-9201(03)00156-0 ';}  ;
    params.cammarano.dG_dT =  -0.014 * 1e9 ; % Pa/K
    params.cammarano.dG_dP = 1.4; % unitless,  Pa/Pa or GPa/GPa
    params.cammarano.dG_dP2 = 0.0;  % 1 / Pa
    params.cammarano.dK_dT = -0.017 * 1e9 ; % Pa/K
    params.cammarano.dK_dP = 4.2; % unitless,  Pa/Pa or GPa/GPa
    params.cammarano.dK_dP2 = 0.0;  % 1 / Pa

    params.abramson.citations = {'Abramson, E. H., J. M. Brown, L. J. Slutsky, and J. Zaug. "The elastic constants of San Carlos olivine to 17 GPa." Journal of Geophysical Research: Solid Earth 102, no. B6 (1997): 12253-12263. https://doi.org/10.1029/97JB00682';};
    params.abramson.dG_dP = 1.71; % shear modulus pressure dependence, Pa/Pa
    params.abramson.dG_dP2 = -0.027 / 1e9; % 1 / Pa
    params.abramson.dK_dP = 4.2; % bulk modulus  pressure dependence, Pa/Pa
    params.abramson.dK_dP2 = 0; % 1 / Pa

    params.upper_mantle.T_K_ref = 1300 + 273;
    params.upper_mantle.P_GPa_ref = 3.0;
    params.upper_mantle.Gu_0 = 66.410;
    params.upper_mantle.Ku_0 = 119.88;
    params.upper_mantle.dG_dT = -1.3816e+07 ; %Pa/K
    params.upper_mantle.dG_dP = 1.5734;
    params.upper_mantle.dG_dP2 = 0.0;
    params.upper_mantle.dK_dT = -1.9845e+07; %Pa/K
    params.upper_mantle.dK_dP = 4.4510;
    params.upper_mantle.dK_dP2 = 0.0;
    params.upper_mantle.rho_ref = 3.3231e+03; % kg/ m^3
    descp = ['Values calculated with Abers and Hacker 2016 for a representative upper mantle ' ...
             'pyrolitic composition '];
    params.upper_mantle.description = descp;

    % calculate bulk modulus instead
    params.description='anharmonic scaling from STP to VBR.in.SV.T_K and VBR.in.SV.P_GPa';

    % crustal values (approximate anorthite values calculated using Abers and Hacker 2016)
    % see https://github.com/vbr-calc/vbrPublicData/blob/master/scripts/an_T_P_G_K.m
    % for where these values come from
    params.chi_mixing = 1;
    params.crust.Gu_0 = 40; % effective reference shear modulus for crust [GPa]
    params.crust.Ku_0 = 86; % effective reference shear modulus for crust [GPa]
    params.crust.dG_dT = -3.6 *1e6 ; % Pa/K
    params.crust.dG_dP = 0.011474 ; % GPa/GPa
    params.crust.dG_dP2 = 0.0; % 1/Pa
    params.crust.dK_dT = -4.7 * 1e6; % Pa/K
    params.crust.dK_dP = 0.013032 ; % Pa/Pa
    params.crust.dK_dP2 = 0.0; % 1/Pa


  elseif strcmp(method,'anh_poro')
    params.func_name='el_ModUnrlx_MELT_f'; % the name of the matlab function
    %% parameters for poro-elastic melt effect
    params.Melt_A  = 1.6 ; % 1:2.3 depending upon the wetting angle (see Yoshino).
    params.Melt_Km = 30e9; % melt bulk modulus [Pa], Takei 2002, Table 2
    params.Melt_nu = 0.25 ; % poisson's ratio for melt
    params.citations={'Takei, 2002, "Effect of pore geometry on VP/VS: From equilibrium geometry to crack", JGR Solid Earth, https://doi.org/10.1029/2001JB000522, Appendix A'};
    params.description='poro-elastic correction';
  elseif strcmp(method,'SLB2005')
    params.func_name='el_Vs_SnLG_f'; % the name of the matlab function
    params.citations={'Stixrude and Lithgow‐Bertelloni (2005), "Mineralogy and elasticity of the oceanic upper mantle: Origin of the low‐velocity zone." JGR 110.B3, https://doi.org/10.1029/2004JB002965'};
    params.description='Stixrude and Lithgow‐Bertelloni (2005) fit of upper mantle Vs';
  end

end
