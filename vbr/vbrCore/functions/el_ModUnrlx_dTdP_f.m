function [ VBR ] = el_ModUnrlx_dTdP_f( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = el_ModUnrlx_dTdP_f( VBR )
  %
  % calculates the effects of pressure and temperature on the unrelaxed
  % shear modulus Gu
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.elastic.anharmonic structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in elastic parameters
  ela = VBR.in.elastic.anharmonic;
  nu = ela.nu ;
  % dG_dT0 = ela.dG_dT ; % Pa/K
  % dG_dP0 = ela.dG_dP  ; % dimensionless
  dG_dT0 = VBR.out.elastic.dG_dT ; % Pa/K
  dG_dP0 = VBR.out.elastic.dG_dP  ; % dimensionless
  T_K_ref = ela.T_K_ref ;
  P_Pa_ref = ela.P_Pa_ref ;
  Gu_0=VBR.out.elastic.Gu_0; % Pa

  if isfield(VBR.in.elastic,'Gu_TP') && isfield(VBR.in.elastic,'Ku_TP')
    % Load unrelaxed shear and bulk moduli (at T,P of interest)
    Gu_TP = VBR.in.elastic.Gu_TP; % Pa
    Ku_TP = VBR.in.elastic.Ku_TP; % Pa
    VBR.out.elastic.Gu_0 = Gu_TP; 
    
  elseif isfield(VBR.in.elastic,'Gu_TP') && ~isfield(VBR.in.elastic,'Ku_TP')
    % Load unrelaxed shear modulus (at T,P of interest)
    Gu_TP = VBR.in.elastic.Gu_TP; % Pa
    
    % calculate bulk modulus
    warning(['No Bulk Modulus found. Calculating assuming nu=',num2str(nu)]);
    Ku_TP = calc_Ku(Gu_TP,nu);
  else
      dT = (VBR.in.SV.T_K-T_K_ref);
      dP = (VBR.in.SV.P_GPa*1e9 - P_Pa_ref);
    % calculate shear modulus at T,P of interest
    Gu_TP = calc_Gu(Gu_0,dT,dP,dG_dT0,dG_dP0);

    % calculate bulk modulus
    Ku_TP = calc_Ku(Gu_TP,nu);
  end

  % calculate velocities
  [Vp,Vs] = el_VpVs_unrelaxed(Ku_TP,Gu_TP,VBR.in.SV.rho);

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
  VBR.out.elastic.anharmonic = anharmonic;
end

function Gu_TP = calc_Gu(Gu_0,dT,dP,dG_dT,dG_dP)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Gu_TP = calc_Gu(Gu_0,dT,dP,dG_dT,dG_dP)
  % calculates unrelaxed modulus at temperature, pressure above or below the
  % reference values.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Gu_TP = Gu_0 + dT.*dG_dT + dP.*dG_dP;
end

function Ku = calc_Ku(Gu,nu)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Ku = calc_Ku(Gu,nu)
  % calculates bulk modulus from shear modulus and poisson ratio
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Ku = 2/3 * Gu .* (1+nu)./(1-2*nu);
end
