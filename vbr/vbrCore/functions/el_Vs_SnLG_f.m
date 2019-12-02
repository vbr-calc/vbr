function [VBR] = el_Vs_SnLG_f(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = el_Vs_SnLG_f(VBR)
  %
  % calculates Vs from Stixrude & Lithgow-Bertelloni parameterization
  %
  % reference:
  % Stixrude and Lithgow‐Bertelloni (2005), "Mineralogy and elasticity of the oceanic
  % upper mantle: Origin of the low‐velocity zone." JGR 110.B3,
  % https://doi.org/10.1029/2004JB002965
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure, with following state variables
  %        VBR.in.SV.P_GPa  pressure in GPa
  %        VBR.in.SV.T_K    temperature in K
  % Output:
  % ------
  % VBR.out.elastic.SLB2005.Vs : anharmonic velocity in km/s
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dV_P=0.0380.*(VBR.in.SV.P_GPa);
  dV_T=-0.000378.*(VBR.in.SV.T_K-300);
  VBR.out.elastic.SLB2005.Vs = 4.77 +  dV_P + dV_T ;
end
