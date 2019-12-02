function [params] = Params_Elastic(method)
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
  %
  % Output:
  % ------
  % params    the parameter structure for the elastic method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  params.possible_methods={'anharmonic','anh_poro','SLB2005'};

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

  elseif strcmp(method,'anh_poro')
    params.func_name='el_ModUnrlx_MELT_f'; % the name of the matlab function
    %% parameters for poro-elastic melt effect
    params.Melt_A  = 1.6 ; % 1:2.3 depending upon the wetting angle (see Yoshino).
    params.Melt_Km = 30e9; % melt bulk modulus [Pa], Takei 2002, Table 2

  elseif strcmp(method,'SLB2005')
    params.func_name='el_Vs_SnLG_f'; % the name of the matlab function
  end

end
