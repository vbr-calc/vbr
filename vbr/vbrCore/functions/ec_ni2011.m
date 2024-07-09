function VBR = ec_ni2011(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_ni2011( VBR )
  %
  % Ni et al. estimation of H2O volatile content and melt fraction of 
  % basaltic melt for electrical conductivity in LVZ
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.ni2011_melt structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  % read in electric parameters
  params = VBR.in.electric.ni2011_melt;
  T = VBR.in.SV.T_K; % K (Temmperature)
  phi = VBR.in.SV.phi; % v_f
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  Tcorr = params.Tcorr; % K, Temperature correction
  D = params.D; % partition coefficient

  % Calculations
      Ch2o_m = Ch2o./(D+(1-D).*phi); % ppm, (h2o_melt)
      Ch2o_m = Ch2o_m./1d4; % ppm => wt_f
    
      ls = 2.172-((860.82-204.46*sqrt(Ch2o_m))./(T-Tcorr)); % S/m, Log sigma
      esig = 10.^ls;
    
      % store in VBR structure
      ni2011_melt.esig = esig;
      VBR.out.electric.ni2011_melt = ni2011_melt;
end