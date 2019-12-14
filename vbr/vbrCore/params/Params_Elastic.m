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
  params.possible_methods={'anharmonic','anh_poro','SLB2005'};

  if ~exist('GlobalParams')
    GlobalParams = Params_Global();
  end
  
  if strcmp(method,'anharmonic')
    params.func_name='el_anharmonic'; % the name of the matlab function
    params.anharm_scale_mthd = 'Isaak' ; % Isaak or Cammarano ;

    params.T_K_ref = 300 ;% room temp [K] (THIS WAS AT 1173!!)
    params.P_Pa_ref = 1e5;% 1 atm [Pa]
    params.Gu_0_ol = 81; % olivine reference shear modulus [GPa]
    params.Gu_0_crust = 30; % effective reference shear modulus for crust [GPa]

    if strcmp(params.anharm_scale_mthd,'Isaak')
      % Isaak, 1992
    	params.dG_dT =  -13.6*1e6 ; % Pa/K (so 13.6 is in MPa/K)
    	params.dG_dP = 1.8 ; % unitless ; % Pa/Pa
    elseif strcmp(params.anharm_scale_mthd,'Cammarano')
      % Cammarano et al 2003:
      % Cammarano has G_0 = 81 - 31*X_Fe, for X = 0.9 (Mg# 91), G_0 = 78.2
    	params.dG_dT = -14.0e6 ; % Cammarano 2003) Pa/K (so 13.6 is in MPa/K)
    	params.dG_dP = 1.4 ; %(Cammarano 2003)  unitless ; % Pa/Pa
    end

    params.nu = 0.25 ; % poisson's ratio
    params.citations={'Cammarano et al. (2003), "Inferring upper-mantle temperatures from seismic velocities", Physics of the Earth and Planetary Interiors, Volume 138, Issues 3–4, https://doi.org/10.1016/S0031-9201(03)00156-0 '; ...
                      'Isaak, D. G. (1992), "High‐temperature elasticity of iron‐bearing olivines", J. Geophys. Res., 97( B2), 1871– 1885, https://doi.org/10.1029/91JB02675'};
    params.description='anharmonic scaling from STP to VBR.in.SV.T_K and VBR.in.SV.P_GPa';

  elseif strcmp(method,'anh_poro')
    params.func_name='el_ModUnrlx_MELT_f'; % the name of the matlab function
    %% parameters for poro-elastic melt effect
    params.Melt_A  = 1.6 ; % 1:2.3 depending upon the wetting angle (see Yoshino).
    params.Melt_Km = 30e9; % melt bulk modulus [Pa], Takei 2002, Table 2
    params.citations={'Takei, 2002, "Effect of pore geometry on VP/VS: From equilibrium geometry to crack", JGR Solid Earth, https://doi.org/10.1029/2001JB000522, Appendix A'};
    params.description='poro-elastic correction';
  elseif strcmp(method,'SLB2005')
    params.func_name='el_Vs_SnLG_f'; % the name of the matlab function
    params.citations={'Stixrude and Lithgow‐Bertelloni (2005), "Mineralogy and elasticity of the oceanic upper mantle: Origin of the low‐velocity zone." JGR 110.B3, https://doi.org/10.1029/2004JB002965'};
    params.description='Stixrude and Lithgow‐Bertelloni (2005) fit of upper mantle Vs';
  end

end
