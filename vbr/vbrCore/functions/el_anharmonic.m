function [VBR] = el_anharmonic(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = el_anharmonic(VBR)
  %
  % calculate anharomic moduli
  %
  % Parameters:
  % ----------
  %  VBR    the VBR structure
  %
  % Output:
  % ------
  %  VBR    the VBR structure, with VBR.out.elastic structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % load or calculate shear and bulk moduli
  if isfield(VBR.in.elastic,'Gu_TP') && isfield(VBR.in.elastic,'Ku_TP')
    % Load unrelaxed shear and bulk moduli (at T,P of interest)
    Gu_TP = VBR.in.elastic.Gu_TP; % Pa
    Ku_TP = VBR.in.elastic.Ku_TP; % Pa
  elseif isfield(VBR.in.elastic,'Gu_TP')
    Gu_TP = VBR.in.elastic.Gu_TP; % Pa

    % calculate bulk modulus
    ela = VBR.in.elastic.anharmonic;
    Ku_0=1e9 * ela.Ku_0_ol; % convert to Pa;
    T_K_ref = ela.T_K_ref ;
    P_Pa_ref = ela.P_Pa_ref ;
    dT = (VBR.in.SV.T_K-T_K_ref);
    dP = (VBR.in.SV.P_GPa*1e9 - P_Pa_ref);
    t_scale = ela.temperature_scaling;
    p_scale = ela.pressure_scaling; 
    Ku_TP = calc_Mu(VBR, t_scale, p_scale, 'K', Ku_0, dT, dP);    
  else   
    ela = VBR.in.elastic.anharmonic;

    Gu_0 = 1e9 * ela.Gu_0_ol; % convert to Pa;
    Ku_0 = 1e9 * ela.Ku_0_ol; % convert to Pa;   
    anharmonic.Gu_0 = Gu_0;
    anharmonic.Gu_0 = Ku_0;
    T_K_ref = ela.T_K_ref ;
    P_Pa_ref = ela.P_Pa_ref ;
    dT = (VBR.in.SV.T_K-T_K_ref);
    dP = (VBR.in.SV.P_GPa*1e9 - P_Pa_ref);
    
    % calculate shear and bulk moduls at 
    % at T,P of interest  
    t_scale = ela.temperature_scaling;
    p_scale = ela.pressure_scaling;  
    Gu_TP = calc_Mu(VBR, t_scale, p_scale, 'G', Gu_0, dT, dP);
    Ku_TP = calc_Mu(VBR, t_scale, p_scale, 'K', Ku_0, dT, dP);    
    
    if ela.chi_mixing == 1
      % mixing (no effect if chi == 1)
      [Gu_TP, Ku_TP] = chi_mixing(Gu_TP, Ku_TP, dT, dP, VBR);
    end 
  end 


  % calculate velocities
  [Vp, Vs] = el_VpVs_unrelaxed(Ku_TP,Gu_TP,VBR.in.SV.rho);
  
  % store in VBR structure
  anharmonic.Gu = Gu_TP ;
  anharmonic.Ku = Ku_TP;
  anharmonic.Vpu = Vp;
  anharmonic.Vsu = Vs;
  
  units.Gu = 'Pa'; 
  units.Ku = 'Pa';
  units.Vpu = 'm/s';
  units.Vsu = 'm/s';
  anharmonic.units = units; 
    
  VBR.out.elastic.units = units;
  VBR.out.elastic.anharmonic = anharmonic;
    
end


function M_TP = calc_Mu(VBR, t_scale, p_scale, G_or_K, Mu_0, dT, dP)
  % a generic modulus calculation at temperature, 
  % pressure for the selected temperature and pressure
  % scaling.     

  % field names for G or K derivatives
  dMdT_str = ['d', G_or_K, '_dT'];
  dMdP_str = ['d', G_or_K, '_dP'];
  dMdP2_str = ['d', G_or_K, '_dP2'];

  % actual derivative
  params = VBR.in.elastic.anharmonic;
  dMdT = params.(t_scale).(dMdT_str);
  dMdP = params.(p_scale).(dMdP_str); 
  dMdP2 = params.(p_scale).(dMdP2_str);
  
  % and the calculation
  M_TP = Mu_0 + dMdT * dT + dP * dMdP + dP.^2 * dMdP2;
end 


function [Gu_TP, Ku_TP] = chi_mixing(Gu_TP, Ku_TP, dT, dP, VBR)

  % get crustal G, K
  ela = VBR.in.elastic.anharmonic;
  Gu_0 = ela.crust.Gu_0;
  Ku_0 = ela.crust.Ku_0;
  t_scale = 'crust';
  p_scale = 'crust';
  Gu_TP_c = calc_Mu(VBR, t_scale, p_scale, 'G', Gu_0, dT, dP);
  Ku_TP_c = calc_Mu(VBR, t_scale, p_scale, 'K', Ku_0, dT, dP);

  % voigt average (volumetric weight)
  chi = VBR.in.SV.chi; 
  Gu_TP = chi .* Gu_TP + (1 - chi) .* Gu_TP_c;
  Ku_TP = chi .* Ku_TP + (1 - chi) .* Ku_TP_c;
end 
