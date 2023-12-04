function [ VBR ] = DK2014( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = DK2014( VBR )
  %
  % experimental results on the electrical conductivity in 
  % hydrated olivine single crystals measured under a broader temperature range
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.DK2014_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in eletric parameters
  ele = VBR.in.electric.DK2014_ol;
  T = VBR.in.SV.T_K; % K (Temperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  P = VBR.in.SV.P_GPa * 1e9; % GPa (Pressure)
  
  % Low Temperature Conduction
    S1 = ele.S_1; % S/m    
    Va_1 = ele.Va_1; % cc/mol (activation volume)
    H1 = ele.H_1 + Va_1.*P; % kJ/mol
    R = ele.R_1; % kJ/(mol*K)
    
  % High Temperature Conduction
    S2 = ele.S_2; % S/m
    Va_2 = ele.Va_2; % cc/mol (activation volume)
    H2 = ele.H_2 + Va_2.*P; % kJ/mol
    
    ch2o_o = ele.ch2o_o; % ppm, experimental reference water content
    r = ele.r; % unitless
    
  % calculate arrhenius relation for each conduction mechanism
  esig_1 = arrh_dry(S1,H1,R,T);
  esig_2 = arrh_dry(S2,H2,R,T);
  
  % summation of conduction mechanisms
  esig = esig_1 + esig_2; % S/m
  esig = ((Ch2o./ch2o_o).^r).*esig;
  
  % store in VBR structure
  DK2014_ol.esig_i = esig_1;
  DK2014_ol.esig_h = esig_2;
  DK2014_ol.esig = esig;
  VBR.out.electric.DK2014_ol = DK2014_ol;
end

function sig = arrh_dry(S,H,k,T)
    exponent = -(H)./(k.*T);
    sig = (10^S).*exp(exponent);
end
