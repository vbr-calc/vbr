---
permalink: /vbrmethods/el/anharmonic/
title: ''
---

# `anharmonic`

The anharmonic scaling calculates unrelaxed elastic moduli at elevated temperature and pressure.

## Requires

* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.GPa` pressure in GPa
* `VBR.in.SV.rho` density in kg m<sup>-3</sup>

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output  

Output is stored in `VBR.out.elastic.anharmonic`:

```matlab
>> disp(fieldnames(VBR.out.elastic.anharmonic))

{
  [1,1] = Gu % unrelaxed shear modulus at desired P,T
  [2,1] = Ku % unrelaxed bulk modulus at desired P,T
  [3,1] = Vpu % unrelaxed compressional wave velocity
  [4,1] = Vsu % unrelaxed shear wave velocity
}
```

Additionally, the unrelaxed modulus at reference conditions is returned in `VBR.out.elastic.Gu_0` as an array that is the same size as the input state variables in `VBR.in.SV`.

## Parameters

Some important parameters are
* `VBR.in.elastic.anharmonic.T_K_ref`: reference temperature in K
* `VBR.in.elastic.anharmonic.P_Pa_ref`: reference temperature in Pa
* `VBR.in.elastic.anharmonic.Gu_0_ol`: reference unrelaxed olivine modulus in GPa at reference T, P.
* `VBR.in.elastic.anharmonic.dG_dT`: temperature dependence of modulus in Pa/K (or Pa/C).
* `VBR.in.elastic.anharmonic.dG_dP`: pressure dependence of modulus, unitless.

Default values for reference temperature and pressure are surface conditions.

To view the full list of parameters,
```matlab
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
disp(VBR.in.elastic.anharmonic)
```

To set any parameter to a non-default value, simply set the field before calling `VBR_spine`:

```matlab
VBR.in.SV=struct();
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic'};

% adjust parameters
VBR.in.elastic.anharmonic.Gu_0_ol=74;

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

# the Reference Modulus

The VBR Calculator does not calculate unrelaxed moduli for various compositions. It is expected that the user will have some other means of setting an appropriate modulus value. The user may set `VBR.in.elastic.anharmonic.Gu_0_ol` to any value they see fit, with the warning that the anelastic scalings implemented here are derived from studies on either olivine or olivine-like materials (i.e., borneol) and hence it is not certain whether the fitting parameters used are appropriate for assemblages where that assumption fails.

## `Gu_0_crust`
While the VBR Calculator does not currently apply to non-olivine assemblages, there is a parameter for a crustal modulus, `VBR.in.elastic.anharmonic.Gu_0_crust`. This parameter allows calculation of more realistic velocity profiles in the crust and uppermost mantle at low temperatures below where anelastic affects are negligible.

The effective unrelexed reference modulus is calculated as a linear mixture of `Gu_0_crust` and `Gu_0_ol` where the compositional fraction is set by `VBR.in.SV.chi`, with a value of 1 for pure olivine:

```matlab
Gu = Gu_0_ol .* VBR.in.SV.chi + (1-VBR.in.SV.chi) .* Gu_0_crust;
```

If `VBR.in.SV.chi` is not set by the user, then  `VBR.in.SV.chi` is initialized to a value of 1 everywhere.

Thus, to produce depth profiles, the state variable arrays should correspond to some depth dependence. For an example, see `Projects/vbr_core_examples/CB_008_anharmonic_Guo.m`.
