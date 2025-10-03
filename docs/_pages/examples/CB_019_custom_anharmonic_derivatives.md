---
permalink: /examples/CB_019_custom_anharmonic_derivatives/
title: ""
---

# CB_019_custom_anharmonic_derivatives.m
## contents
```matlab
function VBR = CB_019_custom_anharmonic_derivatives()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CB_019_custom_anharmonic_derivatives.m
  %
  %  Demonstrates how to add your own custom anharmonic scaling to use in
  %  calculating unrelaxed moduli.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % write method list %
  VBR.in.elastic.methods_list={'anharmonic'};

  % set your unrelaxed shear (G) and bulk (K) moduli
  VBR.in.elastic.anharmonic.Gu_0_ol=70; %[GPa]
  VBR.in.elastic.anharmonic.Ku_0_ol=130; %[GPa]

  % create a structure containing the anharmonic derivatives for
  % the shear and bulk moduli. Must define all of these fields.
  % The pressure scaling has an optional second derivative, set
  % to 0 to use a linear scaling. The structure can have any name.
  my_custom_scaling.dG_dT = -10 *1e6; % Pa/K
  my_custom_scaling.dG_dP = 2; % Pa/Pa
  my_custom_scaling.dG_dP2 = 0;

  my_custom_scaling.dK_dT = 1.2 * my_custom_scaling.dG_dT;
  my_custom_scaling.dK_dP = 3 *  my_custom_scaling.dG_dP;
  my_custom_scaling.dK_dP2 = 0;

  % add the structure to the anharmonic input structure
  VBR.in.elastic.anharmonic.my_custom_scaling = my_custom_scaling;

  % tell the VBRc to use the custom scaling for anharmonic
  % temperature and pressure dependence.
  VBR.in.elastic.anharmonic.temperature_scaling = 'my_custom_scaling';
  VBR.in.elastic.anharmonic.pressure_scaling = 'my_custom_scaling';

  % Define the Thermodynamic State as usual %
  VBR.in.SV.T_K=1200:5:1500;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  sz=size(VBR.in.SV.T_K); % temperature [K]
  VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]
  VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]

  % call the spine as usual
  [VBR] = VBR_spine(VBR) ;

end
```
