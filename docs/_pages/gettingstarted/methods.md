---
permalink: /gettingstarted/methods/
title: 'Listing & Setting Methods'
---

At present, the VBR Calculator includes methods for pure elastic, viscous and anelastic material properties. This section describes how to list and specify methods for calculation. To see descriptions of the methods, see the pages on [elastic](), [viscous]() and [anelastic]() methods.

## Listing Methods

To list available methods from a MATLAB command window:

```matlab
>> VBR_list_methods

available anelastic methods:
    eburgers_psp
    andrade_psp
    xfit_mxw
    xfit_premelt

available elastic methods:
    anharmonic
    anh_poro
    SLB2005

available viscous methods:
    HK2003
    HZK2011
    xfit_premelt
```

Each method has a corresponding set of parameters that can be displayed and/or changed. To load the parameters for a given method, `method_name`, you call `Params_Elastic(method_name)`, `Params_Viscous(method_name)` or `Params_Anelastic(method_name)` depending on the proprety type of the method. For example, to load the `xfit_mxw` anelastic method parameters:

```matlab
>> xfit_mxw_params=Params_Anelastic('xfit_mxw');
>> disp(xfit_mxw_params)

  scalar structure containing the fields:

    possible_methods =
    {
      [1,1] = eburgers_psp
      [1,2] = andrade_psp
      [1,3] = xfit_mxw
      [1,4] = xfit_premelt
      [1,5] = andrade_mxw
    }
    citations =
    {
      [1,1] = McCarthy, Takei, Hiraga, 2011 JGR http://dx.doi.org/10.1029/2011JB008384
    }
    func_name = Q_xfit_mxw
    fit = fit1
    beta2 =  1853
    beta2_fit2 =  8.4760
    alpha2 =  0.50000
    tau_cutoff =    1.0000e-11
    tau_cutoff_fit2 =    5.0000e-06
    beta1 =  0.32000
    Alpha_a =  0.39000
    Alpha_b =  0.28000
    Alpha_c =  2.6000
    Alpha_taun =  0.10000
    description = master curve maxwell scaling
    melt_alpha =  25
    phi_c =    1.0000e-05
    x_phi_c =  5
```

Some fields of note include:

- `citations`: relevant references for the method
- `func_name`: the function in `vbr/vbrCore/functions` called for this method
- `description`: a short description of the method

The remaining fields are all of the parameters and arguments needed to apply the method. In the above case, this includes all coefficients for the master curve maxwell scaling.

## Specifying Methods

The above methods are listed by "property type," which is one of `elastic`, `viscous` or `anelastic`. Each property type has a corresponding `methods_list` cell array in the `VBR.in` structure that represents the list of methods to apply:

```matlab
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.viscous.methods_list={'HK2003';'HZK2011'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};
```

After calculations, each property type will have a field in `VBR.out`, beneath which each method also has a field, e.g.:

```matlab
VBR.out.elastic.anharmonic
VBR.out.viscous.HK2003
VBR.out.anelastic.eburgers_psp
VBR.out.anelastic.andrade_psp
```

The fields returned can be displayed by,. e.g,.:

```matlab
disp(fieldnames(VBR.out.elastic.anharmonic))
```
