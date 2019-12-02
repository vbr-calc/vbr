function [Vp,Vs] = el_VpVs_unrelaxed(bulk_mod,shear_mod,rho)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [Vp,Vs] = el_VpVs_unrelaxed(bulk_mod,shear_mod,rho)
  %
  % calculates unrelaxed Vp, Vs from bulk modulus, shear modulus, density
  %
  % Parameters:
  % ----------
  % bulk_mod     bulk modulus in Pa
  % shear_mod    shear modulus in Pa
  % rho          density in kg/m^3
  %
  % Output:
  % ------
  % Vp, Vs    unrelaxed compressional and shear wave velocties in m/s
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Vp = sqrt((bulk_mod + 4/3 * shear_mod)./rho);
  Vs = sqrt(shear_mod./rho);
end
