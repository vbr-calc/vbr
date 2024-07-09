function [ VBR ] = ec_UHO2014( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_UHO2014( VBR )
  %
  % Review of experimental hydrous conductivity of Olivine evaluated with
  % water concentration correction (Withers, 2012)
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.UHO2014_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in electric parameters
  params = VBR.in.electric.UHO2014_ol;
  T = VBR.in.SV.T_K; % K (Temperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  % P = VBR.in.SV.P_GPa * 1e9; % Pa (Pressure)
  P = 0;
  
  % Vacancy Conduction
    Sv = params.S_v; % S/m
    Va_v = params.Va_v; % cc/mol
    Hv = params.H_v + Va_v.*P; % kJ
    
  % Polaron Conduction
    Sp = params.S_p; % S/m
    Va_p = params.Va_p; % cc/mol
    Hp = params.H_p + Va_p.*P; % kJ
    
  % Hydrous Conduction
    Sh = params.S_h; % S/m
    Va_h = params.Va_h; % cc/mol
    Hh = params.H_h + Va_h.*P; % kJ
    R = params.R_h; % kJ/(mol*K)
    a = params.a_h; % unitless
    r = params.r_h; % unitless

  % calculate Arrhenius relation for each conduction mechanism
  esig_v = arrh_dry(Sv,Hv,R,T);
  esig_p = arrh_dry(Sp,Hp,R,T);
  esig_h = arrh_wet(Sh,Hh,R,T,Ch2o,a,r);
  
  % summation of conduction mechanisms
  esig = esig_v + esig_p + esig_h; % S/m
  
  % store in VBR structure
  UHO2014_ol.esig_i = esig_v;
  UHO2014_ol.esig_h = esig_p;
  UHO2014_ol.esig_p = esig_h;
  UHO2014_ol.esig = esig;
  VBR.out.electric.UHO2014_ol = UHO2014_ol;
end

function sig = arrh_dry(S,H,k,T)
    exponent = -(H)./(k.*T);
    sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
 exponent = -(H-a.*(w.^(1/3)))./(k.*T);
    sig = (S).*(w.^r).*exp(exponent);
end
