---
permalink: /vbrmethods/support/thermoprops/
title: ''
---

# ThermodynamicProps()

Calculates pressure and temperature dependent properties:
* density 
* specific heat
* thermal conductiviy
* hydrostatic pressure

## documentation
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Rho,Cp,Kc,P] = ThermodynamicProps(Rho_o,Kc_o,Cp_o,T,z,P0,dTdz_ad,PropType)
%
% calculates density, specific heat and thermal conductivity as a function
% of temperature (and pressure). Also outputs the hydrostatic pressure.
%
% wrapper for MaterialProperties()
% Parameters
% ----------
%  Rho_o   reference density at STP (array or scalar)
%  Kc_o    reference conductivity at STP (array or scalar)
%  Cp_o    reference heat capacity at STP (only used for constant values)
%  T       temperature [K]
%  z       depth array [m]
%  P0      pressure at z=0 [Pa]
%  dTdz_ad adiabatic temperature gradient [K m^-1]
%  PropType  a string flag that specifies dependencies of Kc, rho and Cp.
%            possible flags:
%            'con'      Constant rho, Cp and Kc
%            'P_dep'    pressure dependent rho, constant Cp and Kc
%            'T_dep'    temperature dependent rho, Cp and Kc
%            'PT_dep'   temperature and pressure dependent rho, Cp and Kc
%
% Output
% ------
%  Rho     density [kg m^-3]
%  Cp      specific heat [J kg^-1 K^-1]
%  Kc      thermal conductivity [W m^-1 K^-1]
%  P       hydrostatic pressure [Pa]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
