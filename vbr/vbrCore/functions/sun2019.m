function [ VBR ] = sun2019( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = sun2019( VBR )
  %
  % Hydrogen-Deuterium Interdiffusion on single crystal San Carlos Olivine
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.sun2019_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in eletric parameters
  ele = VBR.in.electric.sun2019_ol;
  T = VBR.in.SV.T; % K (Temperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  P = VBR.in.SV.P; % Pa (Pressure)
  
  k = ele.k_i; % eV/(mol*K)
    % Ionic Conduction
    Si = ele.S_i; % S/m
    Va_i = ele.Va_i; % cc/mol
    Hi = ele.H_i + Va_i.*P; % eV
    
    % Hopping Conduction
    Sh = ele.S_h; % S/m
    Va_h = ele.Va_h; % cc/mol
    Hh = ele.H_h + Va_h.*P; % eV
    
    % Hydrogen Diffusion
    Sd = ele.S; % (m^2)/s  
    Va = ele.Va; % cc/mol
    Hd = ele.H + Va.*P; % kJ/mol    
    R = ele.R; % kJ/(mol*K) 
    a = ele.a; % unitless
    r = ele.r; % unitless
    
    k_B = ele.k_B; % J/K (Nernst-Eistien constant)
    q = ele.q; % C (Elementary charge)

  % calculate arrhenius relation for each conduction mechanism
  esig_i = arrh_dry(Si,Hi,k,T);
  esig_h = arrh_dry(Sh,Hh,k,T);
  D = arrh_wet(Sd,Hd,R,T,Ch2o,a,r);
  esig_p = (D.*Ch2o.*(q^2))./(k_B*T);
  
  % summation of conduction mechanisms
  esig = esig_i + esig_h + esig_p; % S/m
  
  % store in VBR structure
  sun2019_ol.esig_i = esig_i;
  sun2019_ol.esig_h = esig_h;
  sun2019_ol.esig_p = esig_p;
  sun2019_ol.esig = esig;
  VBR.out.electric.sun2019_ol = sun2019_ol;
end

function sig = arrh_dry(S,H,k,T)
    exponent = -(H)./(k.*T);
    sig = (10^S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
 exponent = -(H-a.*(w.^(1/3)))./(k.*T);
    sig = (10^S).*(w.^r).*exp(exponent);
end