---
permalink: /vbrmethods/el/anharmonic/
title: ''
---

# `anharmonic`

The anharmonic method handles the calulation of unrelaxed shear and bulk 
modulus at elevated temperature and pressure as well as unrelaxed shear and 
compressional wave velocities. Note that you can also chose to directly set 
the shear and bulk modulus at the temperature and pressure of interest (see below).

The anharmonic scaling is a simple linear (or polynomial) fit utilizing 
coefficients for the temperature and pressure derivatives with respect to 
temperature and pressure.

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
* `VBR.in.elastic.anharmonic.temperature_scaling`: the temperature scaling to use (see below)
* `VBR.in.elastic.anharmonic.pressure_scaling`: the pressure scaling to use (see below)

Default values for reference temperature and pressure are surface conditions.

To view the full list of parameters,
```matlab
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
disp(VBR.in.elastic.anharmonic)
```

To check the available temperature and pressure scalings:
```
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
disp(VBR.in.elastic.anharmonic.available_pressure_scaling)
{
  [1,1] = cammarano
  [2,1] = abramson
}
disp(VBR.in.elastic.anharmonic.available_temperature_scaling)
{
  [1,1] = isaak
  [2,1] = cammarano
}
```

You can check the individual values for the above scalings (including `citations` fields) by accessing their respective structures, e.g., `VBR.in.elastic.anharmonic.isaak`. 

To set any parameter to a non-default value, simply set the field before calling `VBR_spine`:

```matlab
VBR.in.SV=struct();
VBR.in.SV.T_K = linspace(800,1200,10)+273; % temperature [K]
VBR.in.SV.P_GPa = 2 * ones(size(VBR.in.SV.T_K)); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(size(VBR.in.SV.T_K)); % density [kg m^-3]

% add to elastic methods list
VBR.in.elastic.methods_list={'anharmonic'};

% adjust parameters
VBR.in.elastic.anharmonic.Gu_0_ol=74; % set a different reference modulus
% use Isaak and Abramson for temperature, pressure scaling respectively
VBR.in.elastic.anharmonic.temperature_scale = 'isaak'; 
VBR.in.elastic.anharmonic.pressure_scale = 'abramson';

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

# the Reference Modulus

The VBR Calculator does not calculate unrelaxed moduli for various compositions. It is expected that the user will have some other means of setting an appropriate modulus value. The user may set `VBR.in.elastic.anharmonic.Gu_0_ol` to any value they see fit, with the warning that the anelastic scalings implemented here are derived from studies on either olivine or olivine-like materials (i.e., borneol) and hence it is not certain whether the fitting parameters used are appropriate for assemblages where that assumption fails.

## `Gu_0_crust`
While the VBR Calculator does not currently apply to non-olivine assemblages, there is a parameter structure for a crustal modulus, `VBR.in.elastic.anharmonic.crust` that includes some anorthite-like values for shear 
and bulk moduli and their respective temperature and pressure derivatives. This parameter allows calculation of more realistic velocity profiles in the crust and uppermost mantle at low temperatures below where anelastic affects are negligible but where having some velocity values may be useful for comparing to observed velocities.

The effective unrelexed modulus is calculated as a linear mixture of the crustal and olivine endmember moduli
at temperature and pressure of interest with the compositional fraction set by `VBR.in.SV.chi`, with a value of 1 for pure olivine, e.g.,:

```matlab
Gu = Gu_ol .* VBR.in.SV.chi + (1-VBR.in.SV.chi) .* Gu_crust;
```

If `VBR.in.SV.chi` is not set by the user, then  `VBR.in.SV.chi` is initialized to a value of 1 everywhere, which corresponds to having no effect. You can also trun this off entirely by setting `VBR.in.elastic.anharmonic.chi_mixing=0`. 

Thus, to produce depth profiles, the state variable arrays should correspond to some depth dependence. For an example, see `Projects/vbr_core_examples/CB_008_anharmonic_Guo.m` and `Projects/vbr_core_examples/CB_012_simple_crust.m`.

# Setting unrelaxed moduli at T, P directly

The VBRc relies on a simple linear calculation of the unrelaxed moduli at the
temperature and pressure of interest. It is possible, however, to load in
unrelaxed moduli calculated with other programs (like. e.g., Perplex). To do so,
you can set the following fields:

```matlab
VBR.in.elastic.Gu_TP = ...
VBR.in.elastic.Ku_TP = ...
```

Both `Gu_TP` and `Ku_TP` should be arrays of the same shape as the state variable
arrays. When these fields are present, the anharmonic calculation will simply read
from these fields, allowing you to set their values in any way you see fit (e.g.,
reading from Perplex output or calling your own functions). If you set only the 
shear modulus, the bulk modulus will be calculated with the standard anharmonic
method.
