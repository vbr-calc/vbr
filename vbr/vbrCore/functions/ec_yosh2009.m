function [ VBR ] = ec_yosh2009( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_yosh2009( VBR )
  %
  % calculates the conductivity of San Carlos Olivine Aggregate at 10GPa
  % from temperature and water content
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.yosh2009_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in electric parameters
  ele = VBR.in.electric.yosh2009_ol;
  T = VBR.in.SV.T_K; % K (Temperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  P = VBR.in.SV.P_GPa * 1e9; % Pa (Pressure)
  Ch2o = Ch2o./1d4; % ppm => wt_f

    % Ionic Conduction
    Si = ele.S_i; % S/m
    Va_i = ele.Va_i; % cc/mol
    Hi = ele.H_i + Va_i.*P; % eV
    k = ele.k_i; % eV/(mol*K)
    
    % Hopping Conduction
    Sh = ele.S_h; % S/m
    Va_h = ele.Va_h; % cc/mol
    Hh = ele.H_h + Va_h.*P; % eV
    
    % Proton Conduction
    Sp = ele.S_p; % S/m
    Va_p = ele.Va_p; % cc/mol
    Hp = ele.H_p + Va_p.*P; % eV
    a = ele.a_p; % unitless
    r = ele.r_p; % unitless

  % calculate Arrhenius relation for each conduction mechanism
  esig_i = arrh_dry(Si,Hi,k,T); % ionic conduction
  esig_h = arrh_dry(Sh,Hh,k,T); % small polaron hopping
  esig_p = arrh_wet(Sp,Hp,k,T,Ch2o,a,r); % proton conduction
  
  % summation of conduction mechanisms
  esig = esig_i + esig_h + esig_p; % S/m
  
  % store in VBR structure
  yosh2009_ol.esig_i = esig_i;
  yosh2009_ol.esig_h = esig_h;
  yosh2009_ol.esig_p = esig_p;
  yosh2009_ol.esig = esig;
  VBR.out.electric.yosh2009_ol = yosh2009_ol;
end

function sig = arrh_dry(S,H,k,T)
    exponent = -(H)./(k.*T);
    sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
 exponent = -(H-a.*(w.^(1/3)))./(k.*T);
    sig = (S).*(w.^r).*exp(exponent);
end
