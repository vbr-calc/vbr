function VBR = ec_gail2008(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_gail2008( VBR )
  %
  % explaination of oceanic asthenosphere conductivity by carbonatite present in melt
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.gail2008_melt structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  % read in electric parameters
  ele = VBR.in.electric.gail2008_melt;
  T = VBR.in.SV.T_K; % K (Temmperature)

  S = ele.S; % S/m
  H = ele.H; % KJ
  R = ele.R; % KJ /(K*mol)
   
  % calculation of Carbonatite melt conduction
  exponent = -H./(R.*T);
  esig = S.*exp(exponent);

  % store in VBR structure
 gail2008_melt.esig = esig;
 VBR.out.electric.gail2008_melt = gail2008_melt;
end