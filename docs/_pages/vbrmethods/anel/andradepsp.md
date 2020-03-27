---
permalink: /vbrmethods/anel/andradepsp/
title: ''
---


# `andrade_psp`

Andrade Model with Pseudo-Period Scaling, following Jackson and Faul (2010), Phys. Earth Planet. Inter., [DOI](https://doi.org/10.1016/j.pepi.2010.09.005). This is a single-sample fit of Jackson and Faul (2010) sample 6585 (Table 1 in the reference).

## Requires

The following state variable arrays are required:

```matlab
VBR.in.SV.T_K % temperature [K]
VBR.in.SV.P_GPa % pressure [GPa]
VBR.in.SV.dg_um % grain size [um]
VBR.in.SV.sig_MPa % differential stress [MPa]
VBR.in.SV.phi % melt fraction / porosity
VBR.in.SV.rho % density in kg m<sup>-3</sup>
```
Additionally, `andrade_psp` relies on output from the elastic methods so `anharmonic` MUST be in the `VBR.in.elastic.methods_list`. If `anh_poro` is in the methods list then `andrade_psp` will use the unrelaxed moduli from `anh_poro` (which includes the P,T projection of `anharmonic` plus the poroelastic correction). See the section on [elastic methods](/vbr/vbrmethods/elastic/) for more details.

## Calling Procedure

```matlab
% set required state variables
clear
VBR.in.SV.T_K=700:50:1200;
VBR.in.SV.T_K=VBR.in.SV.T_K+273;
sz=size(VBR.in.SV.T_K); % temperature [K]

% remaining state variables (ISV)
VBR.in.SV.dg_um=3.1*ones(sz);
VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

% set frequency range
VBR.in.SV.f = 1./logspace(-2,4,100);

% set elastic methods list (at least 'anharmonic' is required)
VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};

% set anelastic methods list
VBR.in.anelastic.methods_list={'andrade_psp'};

% call VBR_spine
[VBR] = VBR_spine(VBR) ;
```

## Output  

Output is stored in `VBR.out.anelastic.andrade_psp`:

```matlab
>> disp(fieldnames(VBR.out.anelastic.andrade_psp))

{
  [1,1] = J1
  [2,1] = J2
  [3,1] = Q
  [4,1] = Qinv
  [5,1] = M
  [6,1] = V
  [7,1] = Vave
}
```

The following fields are frequency dependent: `J1`,`J2`,`Q`,`Qinv`,`M` and `V`. 

## Parameters

To view the full list of parameters,
```matlab
VBR.in.anelastic.andrade_psp = Params_Anelastic('andrade_psp');
disp(VBR.in.anelastic.andrade_psp)
```
Any of these parameters can be set before calling `VBR_spine`.

### on the reference modulus

The parameter fits include a value for the reference modulus, temperature and pressure:

```matlab
G_UR =  62.2
TR =  1173
PR =  0.20000    
```    
which reflect the experimental conditions.

It is important to stress that these values **are not used by the anharmonic** calculation (as a result the reference modulus here **is not used anywhere**). The reference temperature and pressure are only used in calculating maxwell times when calculating the effective diffusion creep viscosity and **do not match the reference values used by the anharmonic methods**. In order to use the exact unrelaxed reference modulus of Jackson and Faul, 2010, you must either (1) overwrite `VBR.in.elastic.anharmonic.Gu_0_ol` using the JF10 value projected to the surface, as done in `Projects/1_LabData/1_Attenuation/FitData_FJ10_Andrade.m` or (2) set `VBR.in.elastic.anharmonic.Gu_0_ol` to the exact JF10 value but then change `VBR.in.elastic.anharmonic.T_K_ref` and `VBR.in.elastic.anharmonic.P_Pa_ref` to match the the JF10 values.

# Example at Laboratory Conditions
The script `Projects/1_LabData/1_Attenuation/FitData_FJ10_Andrade.m` calculates the modulus, M, and attenuation, Q<sup>-1</sup>, for a temperature range of 700-1200<sup>o</sup>C in 50<sup>o</sup>C increments for periods in 10<sup>-2</sup> to 10<sup>4</sup> s following Jackson and Faul (2010):

!['andradeLab'](/vbr/assets/images/FJ10andrade.png){:class="img-responsive"}

Data are from figure 1e-1f of Jackson and Faul 2010 and are not included in the present repository.
