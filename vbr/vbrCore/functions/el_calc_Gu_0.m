function [VBR] = el_calc_Gu_0(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = el_calc_Gu_0(VBR)
  %
  % calculate reference shear modulus using a compositional mixing model between
  % a crust and mantle reference modulus.
  %
  % Parameters:
  % ----------
  % VBR.   structure with following fields
  %    .in.SV.chi   composition (1 = olivine, 0 = crustal assemblage)
  %    .in.elastic.anharmonic.Gu_0_ol  olivine reference shear modulus [GPa]
  %    .in.elastic.anharmonic.Gu_0_crust crustal reference shear modulus [GPa]
  %
  % Output:
  % ------
  % VBR.out.elastic.Gu_0   unrelaxed reference shear modulus in Pa
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Gu_0 = VBR.in.elastic.anharmonic.Gu_0_ol;  % reference moduls in GPa;

  chi = VBR.in.SV.chi; % compositional component
  Gc = VBR.in.elastic.anharmonic.Gu_0_crust;
  Gu = Gu_0 .* chi + (1-chi) .* Gc;

  dG_dT_crust=VBR.in.elastic.anharmonic.dG_dT_crust;
  dG_dT=VBR.in.elastic.anharmonic.dG_dT.*chi+(1-chi).*dG_dT_crust;

  dG_dP_crust=VBR.in.elastic.anharmonic.dG_dP_crust;
  dG_dP=VBR.in.elastic.anharmonic.dG_dP.*chi+(1-chi).*dG_dP_crust;

  VBR.out.elastic.Gu_0=1e9*Gu; % convert to Pa;
  VBR.out.elastic.dG_dT=dG_dT; % convert to Pa;
  VBR.out.elastic.dG_dP=dG_dP; % convert to Pa;

end
