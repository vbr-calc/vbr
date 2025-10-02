---
permalink: /vbrmethods/anel/maxwellanalytical/
title: ''
---


# `maxwell_analytical`

The `maxwell_analytical` method is an implementation of the analytical Maxwell model in the frequency domain, following Lau and Hotlzman, 2019, [doi:10.1029/2019GL083529](https://doi.org/10.1029/2019GL083529).

This method is new as of VBR version v2.1.0.

## Requires

The following state variable arrays are required with the default behavior of `maxwell_analytical`. Most of these variables are **indirectly** required: the `maxwell_analytical` method will pull results from `anharmonic` and `viscous` calculations:

```matlab
VBR.in.SV.T_K % temperature [K]
VBR.in.SV.P_GPa % pressure [GPa]
VBR.in.SV.dg_um % grain size [um]
VBR.in.SV.sig_MPa % differential stress [MPa]
VBR.in.SV.phi % melt fraction / porosity
VBR.in.SV.rho % density in kg m<sup>-3</sup>
```

**Required Elastic Methods**: `anharmonic` MUST be in the `VBR.in.elastic.methods_list`. If `anh_poro` is set, then `maxwell_analytical` will use the unrelaxed moduli from `anh_poro` (which includes the P,T projection of `anharmonic` plus the poroelastic correction). See the section
on [elastic methods](/vbr/vbrmethods/elastic/) for more details.

**Required Viscous Methods**: The default behavior requires at least one [`viscous` method](/vbr/vbrmethods/viscous/) to be set. If multiple are defined, `maxwell_analytical` will use the first in the list. The default behavior uses the diffusion creep viscosity from the specified viscous method as the steady state viscosity within the Maxwell model.

## Calling Procedure

The following calculates frequency dependence for a single thermodynamic state. The `SV` arrays can also be arbitrary sized arrays.

```matlab
VBR.in.elastic.methods_list={'anharmonic';};
VBR.in.viscous.methods_list={'HZK2011'};
VBR.in.anelastic.methods_list={'maxwell_analytical';};

%% Define the Thermodynamic State %%

% set state variables
n1 = 1;
VBR.in.SV.P_GPa = 2 * ones(n1,1); % pressure [GPa]
VBR.in.SV.T_K = 1473 * ones(n1,1); % temperature [K]
VBR.in.SV.rho = 3300 * ones(n1,1); % density [kg m^-3]
VBR.in.SV.sig_MPa = 10 * ones(n1,1); % differential stress [MPa]
VBR.in.SV.phi = 0.0 * ones(n1,1); % melt fraction
VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,1); % grain size [um]

% frequencies to calculate at
VBR.in.SV.f = logspace(-14,0,50);

% calculate!
VBR = VBR_spine(VBR) ;
```

## Output

Output is stored in `VBR.out.anelastic.maxwell_analytical`:

```matlab
>> disp(fieldnames(VBR.out.anelastic.maxwell_analytical))
{
  [1,1] = J1      % real part of dynamic compliance [1/Pa]
  [2,1] = J2      % complex part of dynamic compliance [1/Pa]
  [3,1] = V       % shear wave velocity [m/s]
  [6,1] = Qinv    % attenuation
  [7,1] = Q       % quality factor
  [8,1] = M       % modulus [Pa]
  [9,1] = Vave    % frequency-averaged shear wave velocity [m/s]
}
```

The following fields are frequency dependent: `J1`,`J2`,`Q`,`Qinv`, `M`, `V`.

## Parameters

To view the full list of parameters,
```matlab
VBR.in.anelastic.maxwell_analytical = Params_Anelastic('maxwell_analytical');
disp(VBR.in.anelastic.maxwell_analytical)
```

### Controlling the viscosity

As mentioned above, the default behavior of `maxwell_analytical` is to use the steady state diffusion creep viscosity from the specified viscous method. For example,

```
VBR.in.elastic.methods_list={'anharmonic';};
VBR.in.viscous.methods_list={'HZK2011'};
VBR.in.anelastic.methods_list={'maxwell_analytical';};
```

Will utilize `VBR.out.viscous.HZK2011.diff.eta` as the steady state viscosity.

You can change this behavior in a number of ways by changing some parameter fields.

First, you can adjust which viscous method is by setting the `viscosity_method_mechanism` field. For example, to use the composite viscosity you would set

```matlab
VBR.in.anelastic.maxwell_analytical = Params_Anelastic('maxwell_analytical');
VBR.in.anelastic.maxwell_analytical.viscosity_method_mechanism = 'eta_total';
```

The value of `viscosity_method_mechanism` must be one of the mechanisms in the viscosity output structure. For example, for `HZK2011`

```
fieldnames(VBR.out.viscous.HZK2011)
ans =
{
  [1,1] = diff
  [2,1] = disl
  [3,1] = gbs
  [4,1] = sr_tot
  [5,1] = eta_total
  [6,1] = units
}
```
`viscosity_method_mechanism` may be `'diff'`, `'disl'`, `'gbs'` or `'eta_total'`.

The second way to adjust the viscosity is by explicitly setting the viscosity. To do this, set the `viscosity_method` to `fixed` and specify a steady state viscosity with `eta_ss`:

```matlab
VBR.in.anelastic.maxwell_analytical = Params_Anelastic('maxwell_analytical');
VBR.in.anelastic.maxwell_analytical.viscosity_method = 'fixed';
VBR.in.anelastic.maxwell_analytical.eta_ss = 1e24;
```

The `eta_ss` value may be a scalar or an array of the same size as the `VBR.in.SV.` arrays.

