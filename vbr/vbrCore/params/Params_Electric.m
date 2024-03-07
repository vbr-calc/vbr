function [params] = Params_Electric(method,GlobalParams)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = Params_Electric(method)
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
  % params    the parameter structure for the electric method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  params.possible_methods={'yosh2009','SEO3','poe2010','sun2019','wang2006','UHO2014','DK2014'};

  if ~exist('GlobalParams')
    GlobalParams = Params_Global();
  end

  if strcmp(method,'yosh2009')
    params.func_name='yosh2009'; % the name of the matlab function
    % Yoshino et al, 2009
    % Ionic Conduction
    params.S_i = 10^4.73; % S/m
    params.H_i = 2.31; % eV
    params.k_i = 8.617e-5; % eV/(mol*K)
    params.Va_i = 0; % cc/mol (activation volume)

    
    % Hopping Conduction
    params.S_h = 10^2.98; % S/m
    params.H_h = 1.71; % eV
    params.k_h = 8.617e-5; % eV/(mol*K)
    params.Va_h = 0; % cc/mol (activation volume)
    
    % Proton Conduction
    params.S_p = 10^1.90; %S/m
    params.H_p = 0.92; % eV
    params.k_p = 8.617e-5; % eV/(mol*K)
    params.a_p = 0.16; % unitless
    params.r_p = 1; % unitless
    params.Va_p = 0; % cc/mol (activation volume)

    params.citations={'Yoshino et al. (2009), "The effect of water on the electrical conductivity of olivine aggregates and its implications for the electrical structure of the upper mantle", Earth and Planetary Science Letters, Volume 288, Issue 1-2, https://doi.org/10.1016/j.epsl.2009.09.032'};
    params.description='Yoshino (or alpha) reconciliation on H for hydrous Olivine conductivities (includes i & h conduction)';

  elseif strcmp(method,'SEO3')
    params.func_name='SEO3'; % the name of the matlab function
    % Constable, 2006
    params.e = 1.602e-19; % C
    params.k = 8.617e-5; % eV/(mol*K)
    params.S_bfe = 5.06e24; % constant defect concentration terms  
    params.H_bfe = 0.357;
    
    params.S_bmg = 4.58e26;
    params.H_bmg = 0.752;
    
    params.S_ufe = 12.2e-6;
    params.H_ufe = 1.05;
    
    params.S_umg = 2.72e-6;
    params.H_umg = 1.09;

%     qfm = -24441.9./T + 13.296; %revised QFM-fO2 from Jones et al 2009
%     fO2 = 10.^qfm;
%     concFe = bfe + (3.33e24)*exp((-0.02)./kT).*fO2.^(1/6);
%     concMg = bmg + (6.21e30)*exp((-1.83)./kT).*fO2.^(1/6); 
%     sT = concFe.*ufe*e + 2*concMg.*umg*e;

    params.citations={'Constable (2009), "SEO3: A new model of olivine electrical conductivity", Geophysical Journal International, Volume 166, Issue 1, https://doi.org/10.1111/j.1365-246X.2006.03041.x'};
    params.description='Constable 2006 Standard Electrical Olivine Model (Anhydrous)';

  elseif strcmp(method,'poe2010')
    params.func_name='poe2010'; % the name of the matlab function
    % Poe et al, 2010
    % hydrous 100 axis
    params.S_H100 = 10^2.59; % S/m   
    params.H_H100 = 1.26; % eV
    params.k_H100 = 8.617e-5; % eV/(mol*K)
    params.a_H100 = 1.18; % unitless
    params.r_H100 = 1; % unitless
    params.Va_H100 = 0; % cc/mol (activation volume)
    
    % hydrous 010 axis
    params.S_H010 = 10^3.46; % S/m   
    params.H_H010 = 1.5; % eV
    params.k_H010 = 8.617e-5; % eV/(mol*K)
    params.a_H010 = 1.43; % unitless
    params.r_H010 = 1; % unitless
    params.Va_H010 = 0; % cc/mol (activation volume)
   
    % hydrous 001 axis
    params.S_H001 = 10^1.02; % S/m   
    params.H_H001 = 0.812; % eV
    params.k_H001 = 8.617e-5; % eV/(mol*K)
    params.a_H001 = 0.70; % unitless
    params.r_H001 = 1; % unitless
    params.Va_H001 = 0; % cc/mol (activation volume)
    
%   Anhydrous params 
    params.S_A100 = 334; % S/m 
    params.H_A100 = 1.46; % eV
    params.Va_A100 = 0; % cc/mol (activation volume)
    
    params.S_A010 = 13.8; % S/m
    params.H_A010 = 1.12; % eV
    params.Va_A010 = 0; % cc/mol (activation volume)
    
    params.S_A001 = 99; % S/m
    params.H_A001 = 1.29; % eV
    params.Va_A001 = 0; % cc/mol (activation volume)
    
    params.k_A = 8.617e-5; % eV/(mol*K)

    params.citations={'Poe et al. (2010), "Electrical conductivity anisotropy of dry and hydrous olivine at 8 GPa", Physics of Earth and Planetary Interiors, Volume 181, Issues 3–4, https://doi.org/10.1016/j.pepi.2010.05.003'};
    params.description='Poe et al 2010 Ol Conductivity for 3 crystal axises (hydrous & anhydrous), Parameters Sigma_0 and alpha are for wt% from Jones et al., 2012';
  
   elseif strcmp(method,'wang2006')
    params.func_name='wang2006'; % the name of the matlab function
    % Wang, 2006
    params.S_H = 10^3.0; % S/m   
    params.H_H = 87; % kJ/mol
    params.R_H = 0.008314; % kJ/(mol*K)
    params.a_H = 0; % unitless
    params.r_H = 0.62; % unitless
    params.Va_H = 0; % cc/mol (activation volume)
    
    params.S_A = 10^2.4; % S/m
    params.H_A = 154; % kJ/mol
    params.R_A = 0.008314; % kJ/(mol*K)
    params.Va_A = 0; % cc/mol (activation volume)

    params.citations={'Wang et al. (2006), "The effect of water on the electrical conductivity of olivine", Nature, Volume 443, doi:10.1038/nature05256'};
    params.description='Wang et al. conductivity of Ol aggregate (hydrous and Anhydrous)';
    
   elseif strcmp(method,'UHO2014')
    params.func_name='UHO2014'; % the name of the matlab function
    % UHO, 2014
    params.H_v = 239; % kJ/mol
    params.S_v = 10^5.07; % S/m
    params.R_v = 0.008314; % kJ/(mol*K)
    params.Va_v = 0; % cc/mol (activation volume)

    params.H_p = 144; % kJ/mol
    params.S_p = 10^2.34; % S/m
    params.R_p = 0.008314; % kJ/(mol*K)
    params.Va_p = 0; % cc/mol (activation volume)
    
    params.H_h = 89; % kJ/mol
    params.S_h = 10^-1.37; % S/m
    params.R_h = 0.008314; % kJ/(mol*K)
    params.a_h = 1.79; % kJ/mol/wt (ppm ^1/3)
    params.r_h = 1; % unitless
    params.Va_h = 0; % cc/mol (activation volume)

    params.citations={'Gardes et al. (2014), "Toward a unified hydrous olivine electrical' ...
        'conductivity law", [GeoChemistry, Geophysics, Geosystems], Volume 15, Issue 12, doi:10.1002/2014GC005496'};
    params.description='Gardes derives universal Ol conductivity law based on labratory database (tested against true petrophysical data) ';

  elseif strcmp(method,'jones2012')
    params.func_name='jones2012'; % the name of the matlab function

    % Jones et al., 2012 (Hydrous)
    params.jones2012_ol.S = 10.^(3.05); % S/m
    params.jones2012_ol.r = 0.86; % unitless
    params.jones2012_ol.H = 0.91; % eV
    params.jones2012_ol.a = 0.09; % unitless
    params.jones2012_ol.Va = 0; % cc/mol (activation volume)
    params.jones2012_ol.k = 8.617e-5; % eV/(mol*K)

    params.citations={'Jones et al. (2012), "Water in cratonic lithosphere: Calibrating laboratory- determined models ..."' ...
        'Geochemistry, Geophysics, Geosystems, Volume 13, http://dx.doi.org/10.1029/2012GC004055'};
    params.description='Jones et al. calibration of hydrous electrical conductivity from previous labratory experiments to South African Jagersfontein and Gibeon Xenolith in situ, Constable 2006(SEO3) used as the anhydrous component';
end
  
end
