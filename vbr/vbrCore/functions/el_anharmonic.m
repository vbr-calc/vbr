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
  [VBR] = el_calc_Gu_0(VBR); % set reference shear modulus
  [VBR] = el_ModUnrlx_dTdP_f(VBR) ; % calculate anharmonic scaling with T, P of interest
end
