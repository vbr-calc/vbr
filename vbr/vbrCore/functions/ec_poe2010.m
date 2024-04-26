function [ VBR ] = ec_poe2010( VBR )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_poe2010( VBR )
  %
  % calculations of electrical conductivity in single crystal San Carlos 
  % olivine (Fo90 ) at 8 GPa were determined by complex impedance spectroscopy.
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.poe2010_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in electric parameters
  ele = VBR.in.electric.poe2010_ol;
  T = VBR.in.SV.T_K; % K (Temmperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  P = VBR.in.SV.P_GPa * 1e9; % Pa (Pressure)
  Ch2o = Ch2o./1d4; % ppm => wt_f


  % hydrous 100 axis
    S_H100 = ele.S_H100; % S/m   
    Va_H100 = ele.Va_H100; % cc/mol
    H_H100 = ele.H_H100 + Va_H100.*P; % eV
    a_H100 = ele.a_H100; % unitless
    r = ele.r_H100; % unitless
    k = ele.k_H100; % eV/(mol*K)
    
    % hydrous 010 axis
    S_H010 = ele.S_H010; % S/m 
    Va_H010 = ele.Va_H010; % cc/mol
    H_H010 = ele.H_H010 + Va_H010.*P; % eV
    a_H010 = ele.a_H010; % unitless
    
    % hydrous 001 axis
    S_H001 = ele.S_H001; % S/m 
    Va_H001 = ele.Va_H001; % cc/mol
    H_H001 = ele.H_H001 + Va_H001.*P; % eV
    a_H001 = ele.a_H001; % unitless
    
%   Anhydrous params 
    S_A100 = ele.S_A100; % S/m 
    Va_A100 = ele.Va_A100; % cc/mol
    H_A100 = ele.H_A100 + Va_A100.*P; % eV
    
    S_A010 = ele.S_A010; % S/m
    Va_A010 = ele.Va_A010; % cc/mol
    H_A010 = ele.H_A010 + Va_A010.*P; % eV
    
    S_A001 = ele.S_A001; % S/m
    Va_A001 = ele.Va_A001; % cc/mol
    H_A001 = ele.H_A001 + Va_A001.*P; % eV
    
  % calculate hydrous arrhenius relation for each crystal axis
     esig_H100 = arrh_wet(S_H100,H_H100,k,T,Ch2o,a_H100,r);
     esig_H010 = arrh_wet(S_H010,H_H010,k,T,Ch2o,a_H010,r);
     esig_H001 = arrh_wet(S_H001,H_H001,k,T,Ch2o,a_H001,r);
     esig_H = (esig_H001+esig_H010+esig_H100).^(1/3);
     
  % calculate anhydrous arrhenius relation for each crystal axis
     esig_A100 = arrh_dry(S_A100,H_A100,k,T);
     esig_A010 = arrh_dry(S_A010,H_A010,k,T);
     esig_A001 = arrh_dry(S_A001,H_A001,k,T);
     esig_A = (esig_A001.*esig_A010.*esig_A100).^(1/3);

     
     
  % summation of conduction mechanisms
  esig = esig_H + esig_A; % S/m
  
  % store in VBR structure
  poe2010_ol.esig_H = esig_H;
  poe2010_ol.esig_A = esig_A;
  poe2010_ol.esig = esig;
  VBR.out.electric.poe2010_ol = poe2010_ol;
end

function sig = arrh_dry(S,H,k,T)
    exponent = -(H)./(k.*T);
    sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
 exponent = -(H-a.*(w.^(1/3)))./(k.*T);
    sig = (S).*(w.^r).*exp(exponent);
end
